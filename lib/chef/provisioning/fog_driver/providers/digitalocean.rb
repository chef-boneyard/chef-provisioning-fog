#   fog:DigitalOcean:<client id>
class Chef
module Provisioning
module FogDriver
  module Providers
    class DigitalOcean < FogDriver::Driver
      Driver.register_provider_class('DigitalOcean', FogDriver::Providers::DigitalOcean)

      def creator
        ''
      end

      def convergence_strategy_for(machine_spec, machine_options)
        machine_options = Cheffish::MergedConfig.new(machine_options, {
                                                       :convergence_options => {:ohai_hints => {'digital_ocean' => {}}}
                                                     })
        super(machine_spec, machine_options)
      end

      def converge_floating_ips(action_handler, machine_spec, machine_options, server)
        # DigitalOcean does not have floating IPs
      end

      def bootstrap_options_for(action_handler, machine_spec, machine_options)
        bootstrap_options = symbolize_keys(machine_options[:bootstrap_options] || {})
        if bootstrap_options[:key_path] || bootstrap_options[:key_name]
          bootstrap_options[:key_name] ||= File.basename(bootstrap_options[:key_path])
          # Verify that the provided key name and path are in line (or create the key pair if not!)
          driver = self
          Provisioning.inline_resource(action_handler) do
            fog_key_pair bootstrap_options[:key_name] do
              private_key_path bootstrap_options[:key_path]
              driver driver
            end
          end
        else
          bootstrap_options[:key_name] ||= overwrite_default_key_willy_nilly(action_handler, machine_spec)
        end

        bootstrap_options[:tags]  = default_tags(machine_spec, bootstrap_options[:tags] || {})

        if !bootstrap_options[:image_id] && !bootstrap_options[:image]
          if !bootstrap_options[:image_distribution] && !bootstrap_options[:image_name]
            bootstrap_options[:image_distribution] = 'CentOS'
            bootstrap_options[:image_name] = '6.5 x64'
          end
          distributions = compute.images.select { |image| image.distribution == bootstrap_options[:image_distribution] }
          if distributions.empty?
            raise "No images on DigitalOcean with distribution #{bootstrap_options[:image_distribution].inspect}"
          end
          images = distributions.select { |image| image.name == bootstrap_options[:image_name] } if bootstrap_options[:image_name]
          if images.empty?
            raise "No images on DigitalOcean with distribution #{bootstrap_options[:image_distribution].inspect} and name #{bootstrap_options[:image_name].inspect}"
          end
          bootstrap_options[:image] = images.first.id
        end
        if !bootstrap_options[:flavor_id] && !bootstrap_options[:size]
          bootstrap_options[:flavor_name] ||= '512MB'
          flavors = compute.flavors.select do |f|
            f.slug.downcase == bootstrap_options[:flavor_name].downcase
          end
          if flavors.empty?
            raise "Could not find flavor named '#{bootstrap_options[:flavor_name]}' on #{driver_url}"
          end
          bootstrap_options[:size] = flavors.first.slug
        end
        if !bootstrap_options[:region]
          bootstrap_options[:region_name] ||= 'San Francisco 1'
          regions = compute.regions.select { |region| region.name == bootstrap_options[:region_name] }
          if regions.empty?
            raise "Could not find region named '#{bootstrap_options[:region_name]}' on #{driver_url}"
          end
          bootstrap_options[:region] = regions.first.slug
        end
        keys = compute.ssh_keys.select { |k| k.name == bootstrap_options[:key_name] }
        if keys.empty?
          raise "Could not find key named '#{bootstrap_options[:key_name]}' on #{driver_url}"
        end
        found_key = keys.first
        bootstrap_options[:ssh_keys] ||= [ found_key.id ]

        # You don't get to specify name yourself
        bootstrap_options[:name] = machine_spec.name
        bootstrap_options[:version] ||= :v2
        bootstrap_options
      end

      def destroy_machine(action_handler, machine_spec, machine_options)
        server = server_for(machine_spec)
        if server && server.status != 'archive'
          action_handler.perform_action "destroy machine #{machine_spec.name} (#{machine_spec.location['server_id']} at #{driver_url})" do
            server.delete
          end
        end
        machine_spec.location = nil
        strategy = convergence_strategy_for(machine_spec, machine_options)
        strategy.cleanup_convergence(action_handler, machine_spec)
      end

      def self.compute_options_for(provider, id, config)
        new_compute_options = {}
        new_compute_options[:provider] = provider
        new_config = { :driver_options => { :compute_options => new_compute_options }}
        new_defaults = {
          :driver_options  => { :compute_options => { version: :v2 } },
          :machine_options => { :bootstrap_options => {}, :ssh_options => {} }
        }
        result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

        new_compute_options[:digitalocean_token] = id if (id && id != '')

        [result, new_compute_options[:digitalocean_token]]
      end

    end
  end
end
end
end
