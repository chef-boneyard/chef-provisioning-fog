#fog:XenServer:<XenServer IP>
class Chef
  module Provisioning
    module FogDriver
      module Providers
        class XenServer < FogDriver::Driver

          Driver.register_provider_class('XenServer', FogDriver::Providers::XenServer)

          def creator
            compute_options[:xenserver_username]
          end

          def self.compute_options_for(provider, id, config)
            new_compute_options = {}
            new_compute_options[:provider] = provider
            new_config = { driver_options: { compute_options: new_compute_options } }
            new_defaults = {
                driver_options: { compute_options: {} },
                machine_options: { bootstrap_options: { affinity: id } }
            }
            result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

            new_compute_options[:xenserver_url] = id if id && id != ''
            credential = Fog.credentials

            new_compute_options[:xenserver_username] ||= credential[:xenserver_username]
            new_compute_options[:xenserver_password] ||= credential[:xenserver_password]
            new_compute_options[:xenserver_url] ||= credential[:xenserver_url]
            new_compute_options[:xenserver_timeout] ||= 300
            new_compute_options[:xenserver_redirect_to_master] ||= true

            id = result[:driver_options][:compute_options][:xenserver_url]

            [result, id]
          end

          def server_for(machine_spec)
            if machine_spec.reference
              compute.servers.get(compute.get_by_uuid(machine_spec.reference['server_id'], 'VM'))
            else
              nil
            end
          end

          def servers_for(machine_specs)
            result = {}
            machine_specs.each do |machine_spec|
              if machine_spec.reference
                if machine_spec.reference['driver_url'] != driver_url
                  raise "Switching a machine's driver from #{machine_spec.reference['driver_url']} to #{driver_url} for is not currently supported!  Use machine :destroy and then re-create the machine on the new driver."
                end
                result[machine_spec] = compute.servers.get(compute.get_by_uuid(machine_spec.reference['server_id'], 'VM'))
              else
                result[machine_spec] = nil
              end
            end
            result
          end
          
          def create_many_servers(num_servers, bootstrap_options, parallelizer)
            parallelizer.parallelize(1.upto(num_servers)) do |i|
              server = compute.servers.new(bootstrap_options)
              server.save auto_start: false

              if bootstrap_options[:affinity]
                host = compute.hosts.all.select { |h| h.address == bootstrap_options[:affinity] }.first
                if !host
                  raise "Host with ID #{bootstrap_options[:affinity]} not found."
                end
                server.set_attribute 'affinity', host.reference
              end

              unless bootstrap_options[:memory].nil?
                mem = (bootstrap_options[:memory].to_i * 1024 * 1024).to_s
                server.set_attribute 'memory_limits', mem, mem, mem, mem
              end

              unless bootstrap_options[:cpus].nil?
                cpus = (bootstrap_options[:cpus]).to_s
                server.set_attribute 'VCPUs_max', cpus
                server.set_attribute 'VCPUs_at_startup', cpus
              end

              # network configuration through xenstore
              attrs = {}
              unless bootstrap_options[:network].nil?
                network = bootstrap_options[:network]
                attrs['vm-data/ip'] = network[:vm_ip] if network[:vm_ip]
                attrs['vm-data/gw'] = network[:vm_gateway] if network[:vm_gateway]
                attrs['vm-data/nm'] = network[:vm_netmask] if network[:vm_netmask]
                attrs['vm-data/ns'] = network[:vm_dns] if network[:vm_dns]
                attrs['vm-data/dm'] = network[:vm_domain] if network[:vm_domain]
                if !attrs.empty?
                  server.set_attribute 'xenstore_data', attrs
                end
              end

              server.provision
              yield server if block_given?
              server
            end.to_a
          end

          def start_server(action_handler, machine_spec, server)
            if server.state == 'Halted'
              action_handler.perform_action "start machine #{machine_spec.name} (#{server.id} on #{driver_url})" do
                server.start
                machine_spec.reference['started_at'] = Time.now.to_i
              end
              machine_spec.save(action_handler)
            end
          end

          def converge_floating_ips(action_handler, machine_spec, machine_options, server)
            # XenServer does not have floating IPs
          end
        end
      end
    end
  end
end


# Add methods required by the fog driver to XenServer's Server class
require 'fog/compute/models/server'
module Fog
  module Compute
    class XenServer
      class Server < Fog::Compute::Server
        def id
          uuid
        end

        def state
          attributes[:power_state]
        end

        def public_ip_address
          if xenstore_data['vm-data/ip']
            xenstore_data['vm-data/ip']
          else
            wait_for { tools_installed? }
            if tools_installed?
              guest_metrics.networks.first[1]
            else
              fail 'Unable to return IP address. Virtual machine does not ' \
              'have XenTools installed or a timeout occurred.'
            end
          end
        end

        def ready?
          running?
        end
      end
    end
  end
end

#
# Use call_async instead of call on XMLPRPC::Client
# Otherwise machine_batch will fail since parallel calls will clash.
#
# See http://ruby-doc.org//stdlib-2.1.1//libdoc/xmlrpc/rdoc/XMLRPC/Client.html
# 
module Fog
  module XenServer
    class Connection
      require 'xmlrpc/client'
      attr_reader :credentials

      def request(options, *params)
        begin
          parser = options.delete(:parser)
          method = options.delete(:method)

          if params.empty?
            response = @factory.call_async(method, @credentials)
          else
            if params.length.eql?(1) and params.first.is_a?(Hash)
              response = @factory.call_async(method, @credentials, params.first)
            elsif params.length.eql?(2) and params.last.is_a?(Array)
              response = @factory.call_async(method, @credentials, params.first, params.last)
            else
              response = eval("@factory.call_async('#{method}', '#{@credentials}', #{params.map { |p| p.is_a?(String) ? "'#{p}'" : p }.join(',')})")
            end
          end
          raise RequestFailed.new("#{method}: " + response["ErrorDescription"].to_s) unless response["Status"].eql? "Success"
          if parser
            parser.parse(response["Value"])
            response = parser.response
          end

          response
        end
      end
    end

  end
end

module Fog
  class Logger
    def self.deprecation(message)
      # Silence...ahh
      Chef::Log.debug('Fog: ' + message)
    end
  end
end
