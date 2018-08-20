class Chef
  module Provisioning
    module FogDriver
      module Providers
        class CloudStack < FogDriver::Driver
          Driver.register_provider_class("CloudStack", FogDriver::Providers::CloudStack)

          def creator
            ""
          end

          def self.compute_options_for(provider, id, config)
            new_compute_options = {}
            new_compute_options[:provider] = provider
            new_config = { driver_options: { compute_options: new_compute_options } }
            new_defaults = {
              driver_options: { compute_options: {} },
              machine_options: { bootstrap_options: {} }
            }
            result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

            if id && id != ""
              cloudstack_uri = URI.parse(id)
              new_compute_options[:cloudstack_scheme] = cloudstack_uri.scheme
              new_compute_options[:cloudstack_host]   = cloudstack_uri.host
              new_compute_options[:cloudstack_port]   = cloudstack_uri.port
              new_compute_options[:cloudstack_path]   = cloudstack_uri.path
            end

            host   = result[:driver_options][:compute_options][:cloudstack_host]
            path   = result[:driver_options][:compute_options][:cloudstack_path]    || "/client/api"
            port   = result[:driver_options][:compute_options][:cloudstack_port]    || 443
            scheme = result[:driver_options][:compute_options][:cloudstack_scheme]  || "https"
            id = URI.scheme_list[scheme.upcase].build(host: host, port: port, path: path).to_s

            [result, id]
          end
        end
      end
    end
  end
end
