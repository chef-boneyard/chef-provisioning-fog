# fog:OpenStack:https://identifyhost:portNumber/v2.0

require 'fog/scaleway'
require 'fog/scaleway/models/compute/server'

#
# We're monkeypatching here to avoid overriding too much of the base
# class. This monkey patch will be removed if we can merge those changes
# upstream
#
class Fog::Scaleway::Compute::Server
  alias :start :poweron
  alias :stop :poweroff

  def disassociate_address(ip)
    ip = ip.address if ip.respond_to? :address
    if public_ip && public_ip.address == ip
      public_ip.server = nil
      public_ip.save
    end
    reload
  end
end

class Chef
module Provisioning
module FogDriver
  module Providers
    class Scaleway < FogDriver::Driver
      Driver.register_provider_class('Scaleway', FogDriver::Providers::Scaleway)

      def creator
        compute_options[:scaleway_organization]
      end

      def convergence_strategy_for(machine_spec, machine_options)
        machine_options = Cheffish::MergedConfig.new(machine_options, {
                                                       :convergence_options => {:ohai_hints => {'scaleway' => {}}}
                                                     })
        super(machine_spec, machine_options)
      end

      def bootstrap_options_for(action_handler, machine_spec, machine_options)
        opts = super
        opts[:tags] = opts[:tags].map { |key, value| [key, value].join('=') }

        # Let's fetch the id of the volumes if the user didn't provide it
        # Which probably means they were created in chef
        if opts[:volumes]
          managed_entry_store = machine_spec.managed_entry_store
          volumes = Marshal.load(Marshal.dump(opts[:volumes]))

          volumes.each do |index, volume|
            unless volume[:id]
              volume_spec = managed_entry_store.get(:volume, volume[:name])
              unless volume_spec
                raise "Volume #{volume[:name]} unknown, create it or provide its id"
              end
              volume[:id] = volume_spec.reference['id']
            end
          end
          opts[:volumes] = volumes
        end
        opts
      end

      def destroy_machine(action_handler, machine_spec, machine_options)
        server = server_for(machine_spec)
        if server
          action_handler.perform_action "destroy machine #{machine_spec.name} (#{machine_spec.reference['server_id']} at #{driver_url})" do

            # Scaleway's API fail if we try to stop/terminate an instance with
            # certains states
            if server.state == 'running'
              server.stop
              server.wait_for { server.state != 'running' }
            end
            ['stopping', 'starting'].each do |state|
              server.wait_for { server.state != state } if server.state == state
            end

            if server.state == 'stopped'
              server.destroy
            else
              Chef::log.fatal "Server is in an unknown state (#{server.state})"
            end
            machine_spec.reference = nil
          end
        end
        strategy = ConvergenceStrategy::NoConverge.new(machine_options[:convergence_options], config)
        strategy.cleanup_convergence(action_handler, machine_spec)
      end

      def stop_machine(action_handler, machine_spec, machine_options)
        server = server_for(machine_spec)
        if server and server.state == 'running'
          action_handler.perform_action "stop machine #{machine_spec.name} (#{server.id} at #{driver_url})" do
            server.poweroff(true)
            server.wait_for { server.state == 'stopped' }
          end
        end
      end

      def self.compute_options_for(provider, id, config)
        new_compute_options = {}
        new_compute_options[:provider] = provider
        if (id && id != '')
          org, region = id.split(':')
          new_compute_options[:scaleway_organization] = org
          new_compute_options[:scaleway_region] = region || 'par1'
        end
        new_config = { :driver_options => { :compute_options => new_compute_options }}

        new_default_compute_options = {}
        new_defaults = {
          :driver_options => { :compute_options => new_default_compute_options },
          :machine_options => { :bootstrap_options => {} }
        }

        result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

        credential = Fog.credentials
        new_default_compute_options[:scaleway_organization] ||= credential[:scaleway_organization]
        new_default_compute_options[:scaleway_token] ||= credential[:scaleway_token]

        id = [result[:driver_options][:compute_options][:scaleway_organization],
              result[:driver_options][:compute_options][:scaleway_region]].join(':')

        [result, id]
      end

      def converge_floating_ips(action_handler, machine_spec, machine_options, server)
        if server.dynamic_ip_required
          Chef::Log.info "Dynamic IP allocation has been enabled, not converging IPs"
        else
          super
        end
      end

      # Scaleway only has one global pool.
      def attach_ip_from_pool(server, pool)
        return server if server.public_ip

        Chef::Log.info "Scaleway has only one IP pool, ignoring pool argument"
        ip = server.service.ips.all.select { |ip| ip.address.nil? }.first
        if ip
          ip.server = server
          ip.save
          server.reload
        else
          # Allocate a new IP
          ip = server.service.ips.create
          ip.server = server
          ip.save
          server.reload
        end
      end

      def attach_ip(server, floating_ip)
        ip = server.service.ips.get(floating_ip)
        if ip.nil?
          raise RuntimeError, "Requested IP (#{floating_ip}) not found"
        end
        if ip.server and ip.server.identity != server.identity
          raise RuntimeError, "Requested IP (#{floating_ip}) already attached"
        end

        if server.public_ip
          old_ip = server.public_ip
          Chef::Log.info "Server #{server.identity} already has IP #{old_ip.address}, removing it"
          old_ip.server = nil
          old_ip.save
        end

        ip.server = server
        ip.save
        server.reload
      end

      # Get the public IP if any
      def find_floating_ips(server, action_handler)
        public_ips = []
        Retryable.retryable(RETRYABLE_OPTIONS) do |retries, _exception|
          action_handler.report_progress "Querying for public IP attached to server #{server.id}, API attempt #{retries+1}/#{RETRYABLE_OPTIONS[:tries]} ..."
          public_ips << server.public_ip.address if server.public_ip
        end
        public_ips
      end


      def create_volume(action_handler, volume_spec, volume_options)
        # Prevent destructive operations on volume_options.
        clean_volume_options = Marshal.load(Marshal.dump(volume_options))

        volume_spec.reference ||= {}
        volume_spec.reference.update(
          'driver_url' => driver_url,
          'driver_version' => FogDriver::VERSION,
          'creator' => creator,
          'allocated_at' => Time.now.to_i,
        )

        description = ["Creating volume #{volume_spec.name}"]
        volume_options.each { |k, v| description << "  #{k}: #{v.inspect}"}

        action_handler.report_progress description
        if action_handler.should_perform_actions
          clean_volume_options['name'] = volume_spec.name

          volume = compute.volumes.create(clean_volume_options)

          volume_spec.reference.update(
            'id' => volume.id,
            'volume_type' => volume.volume_type,
            'size' => volume.size
          )
          volume_spec.save(action_handler)
          action_handler.performed_action "volume #{volume_spec.name} created as #{volume.id} on #{driver_url}"
        end
      end

      def destroy_volume(action_handler, volume_spec, volume_options)
        volume = volume_for(volume_spec)

        if volume && action_handler.should_perform_actions
          begin
            msg = "destroyed volume #{volume_spec.name} at #{driver_url}"
            action_handler.perform_action msg do
              volume.destroy
              volume_spec.reference = nil
              volume_spec.save(action_handler)
            end
          rescue Fog::Scaleway::Compute::InvalidRequestError => e
            Chef::Log.error "Unable to destroy volume #{volume_spec.name} : #{e.message}"
          end
        end
      end

      def volume_for(volume_spec)
        if volume_spec.reference
          compute.volumes.get(volume_spec.reference['id'])
        end
      end
    end
  end
end
end
end
