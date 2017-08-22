require 'base64'
require 'uri'
require 'fog/softlayer'
require 'fog/softlayer/models/compute/server'

# fog:SoftLayer:<datacenter>
class Chef
  module Provisioning
    module FogDriver
      module Providers
        class SoftLayer < FogDriver::Driver
          Driver.register_provider_class('SoftLayer', FogDriver::Providers::SoftLayer)

          POST_SCRIPT_DONE = 'post-script-done'

          def creator
            compute_options[:softlayer_username]
          end

          def convergence_strategy_for(machine_spec, machine_options)
            machine_options = Cheffish::MergedConfig.new(machine_options, {
                                                           :convergence_options => {:ohai_hints => {'softlayer' => {}}}
                                                         })
            super(machine_spec, machine_options)
          end

          def self.compute_options_for(provider, id, config)
            new_compute_options = {}
            new_compute_options[:provider] = provider
            new_config = { :driver_options => { :compute_options => new_compute_options }}
            new_defaults = {
              :driver_options => { :compute_options => Fog.credentials },
              :machine_options => { :bootstrap_options => {} }
            }
            result = Cheffish::MergedConfig.new(new_config, config, new_defaults)
            id ||= ''
            new_defaults[:machine_options][:bootstrap_options][:datacenter] = id if not id.empty?

            [result, id]
          end

          def bootstrap_options_for(machine_spec, machine_options)
            # probably best to only ADD options here since super class looks
            # for some values; for example, :key_name doesn't get saved to
            # chef_provisioning.reference if you remove it here.
            # Therefore, we remove things SoftLayer rejects in
            # create_many_servers just before the actual fog create calls.

            opts = super

            if opts[:key_name]
              key_label = opts[:key_name]
              opts[:key_pairs] = [compute.key_pairs.by_label(key_label)] if key_label.is_a? String
            end

            opts
          end

          def create_many_servers(num_servers, bootstrap_options, parallelizer)
            # need to filter out options that SoftLayer doesn't accept
            opts = bootstrap_options.dup

            # options are passed directly to SoftLayer API and
            # SoftLayer_Hardware_Server rejects requests with unrecognized
            # options
            opts.delete(:vlan) if opts[:vlan] && opts[:private_network_only]

            opts.keep_if do |opt, val|
              ::Fog::Compute::Softlayer::Server.attributes.include?(opt) || opt =~ /private_vlan|vlan/
            end
            # fog-softlayer defines :tags but SoftLayer_Hardware_Server rejects it...
            #opts.delete :tags

            # we hook in our own post-install script which uses userMetadata to
            # tell us when post-install is complete. If the user supplies their
            # own script it will be called by our hook before indicating
            # completion in userData.
            opts[:postInstallScriptUri] = 'https://dal05.objectstorage.service.networklayer.com/v1/AUTH_b1b23a05-1c03-4961-8b08-2339886e476f/dist/sl-post-hook.sh'

            super(num_servers, opts, parallelizer)
          end

          def find_floating_ips(server, action_handler)
            []
          end

          def server_for(machine_spec)
              if machine_spec.reference
                  id = machine_spec.reference['server_id']
                  if id and 0 != id
                    compute.servers.get(id)
                  else
                    sv = compute.servers.new(
                      :uid => machine_spec.reference['uid'],
                      :name => machine_spec.name,
                      :domain => machine_spec.reference['domain']
                    )

                    Chef::Log.info("waiting for server.id")
                    sv.wait_for_id
                    machine_spec.reference['server_id'] = sv.id
                    return sv
                  end
              else
                  nil
              end
          end

          def servers_for(specs_and_options)
            result = {}
            specs_and_options.each do |machine_spec, _machine_options|
              result[machine_spec] = server_for(machine_spec)
            end

            result
          end

          def create_servers(action_handler, specs_and_options, parallelizer, &block)
            super do |machine_spec, server|
              machine_spec.reference['uid'] = server.uid
              machine_spec.reference['domain'] = server.domain
              machine_spec.save(action_handler)
              bootstrap_options = specs_and_options[machine_spec][:bootstrap_options]
              create_timeout = bootstrap_options[:create_timeout] || 3600
              wait_for_id(action_handler, server, create_timeout)
              set_post_install_info(action_handler, server, bootstrap_options)

              block.call(machine_spec, server) if block
            end
          end

          def request(server, path, **options)
              service = server.bare_metal? ? :hardware_server : :virtual_guest
              server.service.request(service, path, options)
          end

          def set_post_install_info(action_handler, server, bootstrap_options)
            existing_user_data = request(server, server.id, :query => {:objectMask => 'userData'}).body['userData']
            Chef::Log.info("userData from SLAPI is #{existing_user_data.inspect}")
            if existing_user_data.is_a? Array
              if existing_user_data.size < 1
                existing_user_data = ''
              else
                existing_user_data = existing_user_data.first.fetch('value', '')
              end
            end
            Chef::Log.info("userData after processing is #{existing_user_data.inspect}")
            # VSI userData is empty; bare metal userData will be an Array
            if existing_user_data.empty?
              action_handler.report_progress("Setting userData to detect post install status.")
              sl_user = compute.instance_variable_get '@softlayer_username'
              sl_key = compute.instance_variable_get '@softlayer_api_key'
              service = server.bare_metal? ? 'Hardware_Server' : 'Virtual_Guest'
              ::Retryable.retryable(:tries => 60, :sleep => 5) do
                update_url = URI::HTTPS.build(
                  :userinfo => "#{sl_user}:#{sl_key}",
                  :host => 'api.service.softlayer.com',
                  :path => "/rest/v3/SoftLayer_#{service}/#{server.id}/setUserMetadata",
                ).to_s

                post_install_info = <<SHELL
##POST_INSTALL_INFO
POSTINST_UPDATE_URL='#{update_url}'
POSTINST_REQUESTED_URL='#{bootstrap_options[:postInstallScriptUri]}'
SHELL

                encoded_info = Base64.strict_encode64(post_install_info)
                Chef::Log.debug("encoded info: #{encoded_info.inspect}")

                res = request(
                  server,
                  "#{server.id}/setUserMetadata",
                  :http_method => 'POST', :body => [
                    [
                        encoded_info
                    ]
                  ]
                )

                raise "Failed to setUserMetadata" unless TrueClass == res.body.class or res.body.first['value']
              end
            end
          end

          def wait_for_id(action_handler, server, create_timeout)
            return if 0 != server.id

            # Cannot use Fog.wait_for because it requires server.id which is
            # not initially available for bare metal.
            server.wait_for_id(create_timeout) do |srv_info|
                srv_id = srv_info ? srv_info['id'] : 'not set yet'
                action_handler.report_progress "waiting for server.id on #{server.name} (#{server.uid}): #{srv_id} #{srv_info}"
            end
          end

          def wait_until_ready(action_handler, machine_spec, machine_options, server)
            super

            action_handler.report_progress "waiting for post-install script on #{server.name} to finish"

            ::Retryable.retryable(:tries => 600, :sleep => 2) do
              action_handler.report_progress "checking post-install status on #{server.name}"
              res = request(server, server.id, :query => 'objectMask=userData')
              userData = res.body['userData']
              value = userData.first['value']

              raise "Waiting for post-install script" unless POST_SCRIPT_DONE == value
            end

            action_handler.report_progress "post-install done on #{server.name}"
          end

          def start_server(action_handler, machine_spec, server)
            ::Retryable.retryable(:tries => 10, :sleep => 2) do
              super
            end
          end
        end
      end
    end
  end
end
