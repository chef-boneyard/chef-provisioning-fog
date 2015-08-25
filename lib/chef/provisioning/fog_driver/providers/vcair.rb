#   fog:Vcair:<client id>
class Chef
  module Provisioning
    module FogDriver
      module Providers
        class Vcair < FogDriver::Driver
          Driver.register_provider_class('Vcair', FogDriver::Providers::Vcair)

          def creator
            Chef::Config[:knife][:vcair_username]
          end

          def compute
            @compute ||= begin
                           Chef::Log.debug("vcair_username #{Chef::Config[:knife][:vcair_username]}")
                           Chef::Log.debug("vcair_org #{Chef::Config[:knife][:vcair_org]}")
                           Chef::Log.debug("vcair_api_host #{Chef::Config[:knife][:vcair_api_host]}")
                           #Chef::Log.debug("vcair_api_version #{Chef::Config[:knife][:vcair_api_version]}")
                           Chef::Log.debug("vcair_show_progress #{Chef::Config[:knife][:vcair_show_progress]}")

                           username = [
                             Chef::Config[:knife][:vcair_username],
                             Chef::Config[:knife][:vcair_org]
                           ].join('@')

                           @auth_params = {
                             :provider => 'vclouddirector', #TODO: see compute_options_for, and grab else where
                             :vcloud_director_username => username,
                             :vcloud_director_password => Chef::Config[:knife][:vcair_password],
                             :vcloud_director_host => Chef::Config[:knife][:vcair_api_host],
                             #:vcair_api_host => Chef::Config[:knife][:vcair_api_host],
                             :vcloud_director_api_version => Chef::Config[:knife][:vcair_api_version],
                             :vcloud_director_show_progress => false
                           }

                           Fog::Compute.new(@auth_params)
                         rescue Excon::Errors::Unauthorized => e
                           error_message = "Connection failure, please check your username and password."
                           Chef::Log.error(error_message)
                           raise "#{e.message}. #{error_message}"
                         rescue Excon::Errors::SocketError => e
                           error_message = "Connection failure, please check your authentication URL."
                           Chef::Log.error(error_message)
                           raise "#{e.message}. #{error_message}"
                         end
          end


          def create_many_servers(num_servers, bootstrap_options, parallelizer)
            parallelizer.parallelize(1.upto(num_servers)) do |i|
              clean_bootstrap_options = Marshal.load(Marshal.dump(bootstrap_options)) # Prevent destructive operations on bootstrap_options.
              vm=nil
              begin
                begin
                  instantiate(clean_bootstrap_options)
                rescue Fog::Errors::Error => e
                  unless e.minor_error_code == "DUPLICATE_NAME"
                    # if it's already there, just use the current one
                    raise e
                  end
                end

                vapp = vdc.vapps.get_by_name(bootstrap_options[:name])
                vm = vapp.vms.find {|v| v.vapp_name == bootstrap_options[:name]}
                update_customization(clean_bootstrap_options, vm)

                if bootstrap_options[:cpus]
                  vm.cpu = bootstrap_options[:cpus]
                end
                if bootstrap_options[:memory]
                  vm.memory = bootstrap_options[:memory]
                end
                update_network(bootstrap_options, vapp, vm)

              rescue Excon::Errors::BadRequest => e
                response = Chef::JSONCompat.from_json(e.response.body)
                if response['badRequest']['code'] == 400
                  message = "Bad request (400): #{response['badRequest']['message']}"
                  Chef::Log.error(message)
                else
                  message = "Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}"
                  Chef::Log.error(message)
                end
                raise message
              rescue Fog::Errors::Error => e
                raise e.message
              end

              yield vm if block_given?
              vm

            end.to_a
          end


          def start_server(action_handler, machine_spec, server)

            # If it is stopping, wait for it to get out of "stopping" transition state before starting
            if server.status == 'stopping'
              action_handler.report_progress "wait for #{machine_spec.name} (#{server.id} on #{driver_url}) to finish stopping ..."
              # vCloud Air
              # NOTE: vCloud Air Fog does not get server.status via http every time
              server.wait_for { server.reload ; server.status != 'stopping' }
              action_handler.report_progress "#{machine_spec.name} is now stopped"
            end

            # NOTE: vCloud Air Fog does not get server.status via http every time
            server.reload

            if server.status == 'off' or server.status != 'on'
              action_handler.perform_action "start machine #{machine_spec.name} (#{server.id} on #{driver_url})" do
                server.power_on
                machine_spec.location['started_at'] = Time.now.to_i
              end
              machine_spec.save(action_handler)
            end
          end


          def server_for(machine_spec)
            if machine_spec.location
              vapp = vdc.vapps.get_by_name(machine_spec.name)

              server = unless vapp.nil?
                         unless vapp.vms.first.nil?
                           vapp.vms.find{|vm| vm.id == machine_spec.location['server_id'] }
                         end
                       end
            else
              nil
            end
          end

          def servers_for(machine_specs)
            result = {}
            machine_specs.each do |machine_spec|
              server_for(machine_spec)
            end
            result
          end

          def ssh_options_for(machine_spec, machine_options, server)
            { auth_methods: [ 'password' ],
              timeout: (machine_options[:ssh_timeout] || 600),
              password: machine_options[:ssh_password]
            }.merge(machine_options[:ssh_options] || {})
          end

          def create_ssh_transport(machine_spec, machine_options, server)
            ssh_options = ssh_options_for(machine_spec, machine_options, server)
            username = machine_spec.location['ssh_username'] || default_ssh_username
            options = {}
            if machine_spec.location[:sudo] || (!machine_spec.location.has_key?(:sudo) && username != 'root')
              options[:prefix] = 'sudo '
            end

            remote_host = nil
            # vCloud Air networking is funky
            #if machine_options[:use_private_ip_for_ssh] # vCloud Air probably needs private ip for now
            if server.ip_address
              remote_host = server.ip_address
            else
              raise "Server #{server.id} has no private or public IP address!"
            end

            #Enable pty by default
            options[:ssh_pty_enable] = true
            options[:ssh_gateway] = machine_spec.location['ssh_gateway'] if machine_spec.location.has_key?('ssh_gateway')

            Transport::SSH.new(remote_host, username, ssh_options, options, config)
          end

          def ready_machine(action_handler, machine_spec, machine_options)
            server = server_for(machine_spec)
            if server.nil?
              raise "Machine #{machine_spec.name} does not have a server associated with it, or server does not exist."
            end

            # Start the server if needed, and wait for it to start
            start_server(action_handler, machine_spec, server)
            wait_until_ready(action_handler, machine_spec, machine_options, server)

            # Attach/detach floating IPs if necessary
            # vCloud Air is funky for network.  VM has to be powered off or you get this error:
            #    Primary NIC cannot be changed when the VM is not in Powered-off state
            # See code in update_network()
            #DISABLED: converge_floating_ips(action_handler, machine_spec, machine_options, server)

            begin
              wait_for_transport(action_handler, machine_spec, machine_options, server)
            rescue Fog::Errors::TimeoutError
              # Only ever reboot once, and only if it's been less than 10 minutes since we stopped waiting
              if machine_spec.location['started_at'] || remaining_wait_time(machine_spec, machine_options) < -(10*60)
                raise
              else
                # Sometimes (on EC2) the machine comes up but gets stuck or has
                # some other problem.  If this is the case, we restart the server
                # to unstick it.  Reboot covers a multitude of sins.
                Chef::Log.warn "Machine #{machine_spec.name} (#{server.id} on #{driver_url}) was started but SSH did not come up.  Rebooting machine in an attempt to unstick it ..."
                restart_server(action_handler, machine_spec, server)
                wait_until_ready(action_handler, machine_spec, machine_options, server)
                wait_for_transport(action_handler, machine_spec, machine_options, server)
              end
            end

            machine_for(machine_spec, machine_options, server)
          end

          def org
            @org ||= compute.organizations.get_by_name(Chef::Config[:knife][:vcair_org])
          end

          def vdc
            if Chef::Config[:knife][:vcair_vdc]
              @vdc ||= org.vdcs.get_by_name(Chef::Config[:knife][:vcair_vdc])
            else
              @vdc ||= org.vdcs.first
            end
          end

          def net
            if Chef::Config[:knife][:vcair_net]
              @net ||= org.networks.get_by_name(Chef::Config[:knife][:vcair_net])
            else
              # Grab first non-isolated (bridged, natRouted) network
              @net ||= org.networks.find { |n| n if !n.fence_mode.match("isolated") }
            end
          end

          def template(bootstrap_options)
            # TODO: find by catalog item ID and/or NAME
            # TODO: add option to search just public and/or private catalogs

            #TODO: maybe make a hash for caching
            org.catalogs.map do |cat|
              #cat.catalog_items.get_by_name(config_value(:image))
              cat.catalog_items.get_by_name(bootstrap_options[:image_name])
            end.compact.first
          end

          def instantiate(bootstrap_options)
            begin
              #node_name = config_value(:chef_node_name)
              node_name = bootstrap_options[:name]
              template(bootstrap_options).instantiate(
                node_name,
                vdc_id: vdc.id,
                network_id: net.id,
                description: "id:#{node_name}")
              #rescue CloudExceptions::ServerCreateError => e
            rescue => e
              raise e
            end
          end

          # Create a WinRM transport for a vCloud Air Vapp VM instance
          # @param [Hash] machine_spec Machine-spec hash
          # @param [Hash] machine_options Machine options (from the recipe)
          # @param [Fog::Compute::Server] server A Fog mapping to the AWS instance
          # @return [ChefMetal::Transport::WinRM] A WinRM Transport object to talk to the server
          def create_winrm_transport(machine_spec, machine_options, server)
            port = machine_spec.location['winrm_port'] || 5985
            endpoint = "http://#{server.ip_address}:#{port}/wsman"
            type = :plaintext

            # Use basic HTTP auth - this is required for the WinRM setup we
            # are using
            # TODO: Improve that and support different users
            options = {
              :user => 'Administrator',
              :pass => machine_options[:winrm_options][:password],
              :disable_sspi => true,
              :basic_auth_only => true
            }
            Chef::Provisioning::Transport::WinRM.new(endpoint, type, options, {})
          end

          def update_customization(bootstrap_options, server)
            ## Initialization before first power on.
            custom=server.customization

            if bootstrap_options[:customization_script]
              custom.script = open(bootstrap_options[:customization_script]).read
            end

            bootstrap_options[:protocol] ||= case server.operating_system
                                         when /Windows/
                                           'winrm'
                                         else
                                           'ssh'
                                         end
            password = case bootstrap_options[:protocol]
                       when 'ssh'
                         bootstrap_options[:ssh_options][:password]
                       when 'winrm'
                         bootstrap_options[:winrm_options][:password]
                       end

            if password
              custom.admin_password =  password
              custom.admin_password_auto = false
              custom.reset_password_required = false
            else
              # Password will be autogenerated
              custom.admin_password_auto=true
              # API will force password resets when auto is enabled
              custom.reset_password_required = true
            end

            # TODO: Add support for admin_auto_logon to Fog
            # c.admin_auto_logon_count = 100
            # c.admin_auto_logon_enabled = true

            # DNS and Windows want AlphaNumeric and dashes for hostnames
            # Windows can only handle 15 character hostnames
            # TODO: only change name for Windows!
            #c.computer_name = config_value(:chef_node_name).gsub(/\W/,"-").slice(0..14)
            custom.computer_name = bootstrap_options[:name].gsub(/\W/,"-").slice(0..14)
            custom.enabled = true
            custom.save
          end

          ## vCloud Air
          ## TODO: make work with floating_ip junk currently used
          ## NOTE: current vCloud Air networking changes require VM to be powered off
          def update_network(bootstrap_options, vapp, vm)
            ## TODO: allow user to specify network to connect to (see above net used)
            # Define network connection for vm based on existing routed network

            # vCloud Air inlining vapp() and vm()
            #vapp = vdc.vapps.get_by_name(bootstrap_options[:name])
            #vm = vapp.vms.find {|v| v.vapp_name == bootstrap_options[:name]}
            return if vm.ip_address != "" # return if ip address is set, as this isn't a new VM
            nc = vapp.network_config.find { |netc| netc if netc[:networkName].match(net.name) }
            networks_config = [nc]
            section = {PrimaryNetworkConnectionIndex: 0}
            section[:NetworkConnection] = networks_config.compact.each_with_index.map do |network, i|
              connection = {
                network: network[:networkName],
                needsCustomization: true,
                NetworkConnectionIndex: i,
                IsConnected: true
              }
              ip_address      = network[:ip_address]
              ## TODO: support config options for allocation mode
              #allocation_mode = network[:allocation_mode]
              #allocation_mode = 'manual' if ip_address
              #allocation_mode = 'dhcp' unless %w{dhcp manual pool}.include?(allocation_mode)
              #allocation_mode = 'POOL'
              #connection[:Dns1] = dns1 if dns1
              allocation_mode = 'pool'
              connection[:IpAddressAllocationMode] = allocation_mode.upcase
              connection[:IpAddress] = ip_address if ip_address
              connection
            end

            ## attach the network to the vm
            nc_task = compute.put_network_connection_system_section_vapp(
              vm.id,section).body
            compute.process_task(nc_task)
          end

          def bootstrap_options_for(action_handler, machine_spec, machine_options)
            bootstrap_options = symbolize_keys(machine_options[:bootstrap_options] || {})

            bootstrap_options[:tags]  = default_tags(machine_spec, bootstrap_options[:tags] || {})
            bootstrap_options[:name] ||= machine_spec.name

            bootstrap_options = bootstrap_options.merge(machine_options.configs[1])
            bootstrap_options
          end

          def destroy_machine(action_handler, machine_spec, machine_options)
            server = server_for(machine_spec)
            if server && server.status != 'archive' # TODO: does vCloud Air do archive?
              action_handler.perform_action "destroy machine #{machine_spec.name} (#{machine_spec.location['server_id']} at #{driver_url})" do
                #NOTE: currently doing 1 vm for 1 vapp
                vapp = vdc.vapps.get_by_name(machine_spec.name)
                if vapp
                  vapp.power_off
                  vapp.undeploy
                  vapp.destroy
                else
                  Chef::Log.warn "No VApp named '#{server_name}' was found."
                end
              end
            end
            machine_spec.location = nil
            strategy = convergence_strategy_for(machine_spec, machine_options)
            strategy.cleanup_convergence(action_handler, machine_spec)
          end

          def self.compute_options_for(provider, id, config)
            new_compute_options = {}
            new_compute_options[:provider] = 'vclouddirector'
            new_config = { :driver_options => { :compute_options => new_compute_options }}
            new_defaults = {
              :driver_options  => { :compute_options => {} },
              :machine_options => { :bootstrap_options => {}, :ssh_options => {} }
            }
            result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

            [result, id]
          end
        end
      end
    end
  end
end
