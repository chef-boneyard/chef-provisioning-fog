require 'fog/joyent'

#   fog:Joyent:<joyent_url>
class Chef
module Provisioning
module FogDriver
  module Providers
    class Joyent < FogDriver::Driver

      Driver.register_provider_class('Joyent', FogDriver::Providers::Joyent)

      def creator
        compute_options[:joyent_username]
      end

      def bootstrap_options_for(machine_spec, machine_options)
        bootstrap_options = symbolize_keys(machine_options[:bootstrap_options] || {})

        bootstrap_options[:tags] = default_tags(machine_spec, bootstrap_options[:tags] || {})

        bootstrap_options[:tags].each do |key, val|
          bootstrap_options["tag.#{key}"] = val
        end

        bootstrap_options[:name] ||= machine_spec.name

        bootstrap_options
      end

      def find_floating_ips(server, action_handler)
        []
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

        new_compute_options[:joyent_url] = id if (id && id != '')
        credential = Fog.credentials

        new_compute_options[:joyent_username] ||= credential[:joyent_username]
        new_compute_options[:joyent_password] ||= credential[:joyent_password]
        new_compute_options[:joyent_keyname] ||= credential[:joyent_keyname]
        new_compute_options[:joyent_keyfile] ||= credential[:joyent_keyfile]
        new_compute_options[:joyent_url] ||= credential[:joyent_url]
        new_compute_options[:joyent_version] ||= credential[:joyent_version]

        id = result[:driver_options][:compute_options][:joyent_url]

        [result, id]
      end

    end
  end
end
end
end
