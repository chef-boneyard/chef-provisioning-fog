class Chef
  module Provisioning
    module FogDriver
      module Providers
        class SoftLayer < FogDriver::Driver
          Driver.register_provider_class('SoftLayer', FogDriver::Providers::SoftLayer)

          def creator
            compute_options[:softlayer_username]
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

            credential = Fog.credentials

            new_compute_options[:softlayer_username] ||= credential[:softlayer_username]
            new_compute_options[:softlayer_api_key] ||= credential[:softlayer_api_key]

            id = result[:driver_options][:compute_options][:softlayer_auth_url]

            [result, id]
          end
        end
      end
    end
  end
end

