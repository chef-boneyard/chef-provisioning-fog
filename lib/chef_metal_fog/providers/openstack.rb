# fog:OpenStack:https://identifyhost:portNumber/v2.0
module ChefMetalFog
  module Providers
    class OpenStack < ChefMetalFog::FogDriver

      ChefMetalFog::FogDriver.register_provider_class('OpenStack', ChefMetalFog::Providers::OpenStack)

      def creator
        compute_options[:openstack_username]
      end

      def self.compute_options_for(provider, id, config)
        new_compute_options = {}
        new_compute_options[:provider] = provider
        new_config = { :driver_options => { :compute_options => new_compute_options }}
        new_defaults = {
          :driver_options => { :compute_options => {} },
          :machine_options => { :bootstrap_options => {} }
        }
        result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

        new_compute_options[:openstack_auth_url] = id if (id && id != '')
        credential = Fog.credentials

        new_compute_options[:openstack_username] ||= credential[:openstack_username]
        new_compute_options[:openstack_api_key] ||= credential[:openstack_api_key]
        new_compute_options[:openstack_auth_url] ||= credential[:openstack_auth_url]
        new_compute_options[:openstack_tenant] ||= credential[:openstack_tenant]

        id = result[:driver_options][:compute_options][:openstack_auth_url]

        [result, id]
      end

      # Check given IP already attached and attach if necessary
      def attach_floating_ips(action_handler, machine_spec, machine_options, server)
        if option_for(machine_options, :floating_ip_pool)
          Chef::Log.info 'Attaching IP from pool'
          action_handler.perform_action "attach floating IP from #{option_for(machine_options, :floating_ip_pool)} pool" do
            pool = option_for(machine_options, :floating_ip_pool)
            allocated_addresses = server.addresses[pool]
            if ! allocated_addresses.nil?
              allocated_addresses.select {|a_info| a_info['OS-EXT-IPS:type']=='floating'}
              if allocated_addresses.length>0
                Chef::Log.info "Address from pool <#{pool}> already allocated"
                return true
              end
            end
            attach_ip_from_pool(server, pool)
          end
        elsif option_for(machine_options, :floating_ip)
          Chef::Log.info 'Attaching given IP'
          action_handler.perform_action "attach floating IP #{option_for(machine_options, :floating_ip)}" do
            ip = option_for(machine_options, :floating_ip)
            allocated_addresses = []
            server.addresses.keys.each do |pool|
              server.addresses[pool].each {|a_info| allocated_addresses<<a_info['addr']}
            end
            if allocated_addresses.include? ip
              Chef::Log.info "Address <#{ip}> already allocated"
            else
              attach_ip(server, ip)
            end
          end
        end
      end

      # Attach given IP to machine
      def attach_ip(server, ip)
        Chef::Log.info "Attaching floating IP <#{ip}>"
        compute.associate_address(server.id, ip)
      end

    end
  end
end
