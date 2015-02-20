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

      def attach_floating_ips(action_handler, machine_spec, machine_options, server)
        # TODO this is not particularly idempotent. OK, it is not idempotent AT ALL.  Fix.
        if option_for(machine_options, :floating_ip_pool)
          Chef::Log.info 'Attaching IP from pool'
          action_handler.perform_action "attach floating IP from #{option_for(machine_options, :floating_ip_pool)} pool" do
            attach_ip_from_pool(server, option_for(machine_options, :floating_ip_pool))
          end
        elsif option_for(machine_options, :floating_ip)
          Chef::Log.info 'Attaching given IP'
          action_handler.perform_action "attach floating IP #{option_for(machine_options, :floating_ip)}" do
            attach_ip(server, option_for(machine_options, :floating_ip))
          end
        end
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
