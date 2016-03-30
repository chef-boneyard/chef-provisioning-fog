# fog:Rackspace:https://identity.api.rackspacecloud.com/v2.0
class Chef
module Provisioning
module FogDriver
  module Providers
    class Rackspace < FogDriver::Driver

      Driver.register_provider_class('Rackspace', FogDriver::Providers::Rackspace)

      def creator
        compute_options[:rackspace_username]
      end

      def convergence_strategy_for(machine_spec, machine_options)
        machine_options = Cheffish::MergedConfig.new(machine_options, {
                                                       :convergence_options => {:ohai_hints => {'rackspace' => {}}}
                                                     })
        super(machine_spec, machine_options)
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

        new_compute_options[:rackspace_auth_url] = id if (id && id != '')
        credential = Fog.credentials

        new_compute_options[:rackspace_username] ||= credential[:rackspace_username]
        new_compute_options[:rackspace_api_key] ||= credential[:rackspace_api_key]
        new_compute_options[:rackspace_auth_url] ||= credential[:rackspace_auth_url]
        new_compute_options[:rackspace_region] ||= credential[:rackspace_region]
        new_compute_options[:rackspace_endpoint] ||= credential[:rackspace_endpoint]

        id = result[:driver_options][:compute_options][:rackspace_auth_url]

        [result, id]
      end

    end
  end
end
end
end
