class Chef
  module Provisioning
    module FogDriver
      module Providers
        class Google < FogDriver::Driver
          Driver.register_provider_class('Google', FogDriver::Providers::Google)

          def creator
            ''
          end

          def convergence_strategy_for(machine_spec, machine_options)
            machine_options = Cheffish::MergedConfig.new(machine_options, {
                                                           :convergence_options => {:ohai_hints => {'gce' => {}}}
                                                         })
            super(machine_spec, machine_options)
          end

          def converge_floating_ips(action_handler, machine_spec, machine_options, server)
          end

          def server_for(machine_spec)
            if machine_spec.name
              compute.servers.get(machine_spec.name)
            else
              nil
            end
          end

          def servers_for(machine_specs)
            result = {}
            machine_specs.each do |machine_spec|
              result[machine_spec] = server_for(machine_spec)
            end
            result
          end

          def bootstrap_options_for(action_handler, machine_spec, machine_options)
            bootstrap_options = symbolize_keys(machine_options[:bootstrap_options] || {})
            bootstrap_options[:image_name] ||= 'debian-7-wheezy-v20150325'
            bootstrap_options[:machine_type] ||= 'n1-standard-1'
            bootstrap_options[:zone_name] ||= 'europe-west1-b'
            bootstrap_options[:name] ||= machine_spec.name
            bootstrap_options[:disk_size] ||= 10
            disk_type_prefix = "https://www.googleapis.com/compute/v1/projects/#{compute_options[:google_project]}/zones/#{bootstrap_options[:zone_name]}/diskTypes/"
            standard_disk_type = disk_type_prefix + 'pd-standard'
            if bootstrap_options[:disk_type].nil?
              bootstrap_options[:disk_type] = standard_disk_type
            else
              bootstrap_options[:disk_type] = disk_type_prefix + bootstrap_options[:disk_type]
            end

            if bootstrap_options[:disks].nil?
              # create the persistent boot disk
              disk_defaults = {
                :name => machine_spec.name,
                :size_gb => bootstrap_options[:disk_size],
                :zone_name => bootstrap_options[:zone_name],
                :source_image => bootstrap_options[:image_name],
                :type => bootstrap_options[:disk_type],
              }

              disk = compute.disks.create(disk_defaults)
              disk.wait_for { disk.ready? }
              bootstrap_options[:disks] = [disk]
            end

            bootstrap_options
          end

          def destroy_machine(action_handler, machine_spec, machine_options)
            server = server_for(machine_spec)
            if server && server.state != 'archive'
              action_handler.perform_action "destroy machine #{machine_spec.name} (#{machine_spec.location['server_id']} at #{driver_url})" do
                server.destroy
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
              :driver_options  => { :compute_options => {} },
              :machine_options => { :bootstrap_options => {}, :ssh_options => {} }
            }
            result = Cheffish::MergedConfig.new(new_config, config, new_defaults)

            [result, '']
          end

        end
      end
    end
  end
end
