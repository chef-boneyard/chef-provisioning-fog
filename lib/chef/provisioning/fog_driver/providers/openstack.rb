# fog:OpenStack:https://identifyhost:portNumber/v2.0
class Chef
module Provisioning
module FogDriver
  module Providers
    class OpenStack < FogDriver::Driver

      Driver.register_provider_class('OpenStack', FogDriver::Providers::OpenStack)

      def creator
        compute_options[:openstack_username]
      end

      def create_winrm_transport(machine_spec, machine_options, server)
        remote_host = if machine_spec.reference['use_private_ip_for_ssh']
                        server.private_ip_address
                      elsif !server.public_ip_address
                        Chef::Log.warn("Server #{machine_spec.name} has no public ip address.  Using private ip '#{server.private_ip_address}'.  Set driver option 'use_private_ip_for_ssh' => true if this will always be the case ...")
                        server.private_ip_address
                      elsif server.public_ip_address
                        server.public_ip_address
                      else
                        fail "Server #{server.id} has no private or public IP address!"
                      end
		Chef::Log::info("Connecting to server #{remote_host}")
		
        port = machine_spec.reference['winrm_port'] || 5985
        endpoint = "http://#{remote_host}:#{port}/wsman"
        type = :plaintext
        decrypted_password = machine_spec.reference['winrm.password'] 

        # Use basic HTTP auth - this is required for the WinRM setup we
        # are using
        # TODO: Improve that.
        options = {
            :user => machine_spec.reference['winrm.username'] || 'Administrator',
            :pass => decrypted_password,
            :disable_sspi => false,
            :basic_auth_only => true
        }

        Chef::Provisioning::Transport::WinRM.new(endpoint, type, options, {})
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

    end
  end
end
end
end
