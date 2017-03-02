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

      def convergence_strategy_for(machine_spec, machine_options)
        machine_options = Cheffish::MergedConfig.new(machine_options, {
                                                       :convergence_options => {:ohai_hints => {'openstack' => {}}}
                                                     })
        super(machine_spec, machine_options)
      end

      def create_winrm_transport(machine_spec, machine_options, server)
        if machine_options[:winrm].nil?
          fail "You must provide winrm settings in machine_options to use the winrm transport!"
        end
        remote_host = determine_remote_host machine_spec, server
        Chef::Log::info("Connecting to server #{remote_host}")
        port = machine_options[:winrm][:port] || 5985
        endpoint = "http://#{remote_host}:#{port}/wsman"
        type = machine_options[:winrm][:type] || :negotiate
        decrypted_password = machine_options[:winrm][:password] || ''
        options = {
            :user => machine_options[:winrm][:username] || 'Administrator',
            :pass => decrypted_password,
            :disable_sspi => !!machine_options[:winrm][:disable_sspi] || false,
            :basic_auth_only => !!machine_options[:winrm][:basic_auth_only] || false
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

        credential = Fog.credentials.find_all{ |k,v|
          k.to_s.start_with?('openstack') }
        credential.each { |k,v|
          new_compute_options[k] ||= v
        }

        id = result[:driver_options][:compute_options][:openstack_auth_url]

        [result, id]
      end

      # Image methods
      def allocate_image(action_handler, image_spec, image_options, machine_spec, machine_options)
        image = image_for(image_spec)
        if image
          raise "The image already exists, why are you asking me to create it?  I can't do that, Dave."
        end
        action_handler.perform_action "Create image #{image_spec.name} from machine #{machine_spec.name} with options #{image_options.inspect}" do
          response = compute.create_image(
            machine_spec.reference['server_id'], image_spec.name,
            {
              description: "The Image named '#{image_spec.name}"
            })

          image_spec.reference = {
            driver_url: driver_url,
            driver_version: FogDriver::VERSION,
            image_id: response.body['image']['id'],
            creator: creator,
            allocated_it: Time.new.to_i
          }
        end
      end

      def ready_image(action_handler, image_spec, image_options)
        actual_image = image_for(image_spec)
        if actual_image.nil?
          raise 'Cannot ready an image that does not exist'
        else
          if actual_image.status != 'ACTIVE'
            action_handler.report_progress 'Waiting for image to be active ...'
            wait_until_ready_image(action_handler, image_spec, actual_image)
          else
            action_handler.report_progress "Image #{image_spec.name} is active!"
          end
        end
      end

      def destroy_image(action_handler, image_spec, image_options)
        image = image_for(image_spec)
        unless image.status == "DELETED"
          image.destroy
        end
      end

      def wait_until_ready_image(action_handler, image_spec, image=nil)
        wait_until_image(action_handler, image_spec, image) { image.status == 'ACTIVE' }
      end

      def wait_until_image(action_handler, image_spec, image=nil, &block)
        image ||= image_for(image_spec)
        time_elapsed = 0
        sleep_time = 10
        max_wait_time = 300
        if !yield(image)
          action_handler.report_progress "waiting for image #{image_spec.name} (#{image.id} on #{driver_url}) to be active ..."
          while time_elapsed < max_wait_time && !yield(image)
           action_handler.report_progress "been waiting #{time_elapsed}/#{max_wait_time} -- sleeping #{sleep_time} seconds for image #{image_spec.name} (#{image.id} on #{driver_url}) to be ACTIVE instead of #{image.status}..."
           sleep(sleep_time)
           image.reload
           time_elapsed += sleep_time
          end
          unless yield(image)
            raise "Image #{image.id} did not become ready within #{max_wait_time} seconds"
          end
          action_handler.report_progress "Image #{image_spec.name} is now ready"
        end
      end

      def image_for(image_spec)
        if image_spec.reference
          compute.images.get(image_spec.reference[:image_id]) || compute.images.get(image_spec.reference['image_id'])
        else
          nil
        end
      end

      def determine_remote_host(machine_spec, server)
        transport_address_location = (machine_spec.reference['transport_address_location'] || :none).to_sym

        if machine_spec.reference['use_private_ip_for_ssh']
          # The machine_spec has the old config key, lets update it - a successful chef converge will save the machine_spec
          # TODO in 2.0 get rid of this update
          machine_spec.reference.delete('use_private_ip_for_ssh')
          machine_spec.reference['transport_address_location'] = :private_ip
          server.private_ip_address
        elsif transport_address_location == :ip_addresses
          server.ip_addresses.first
        elsif transport_address_location == :private_ip
          server.private_ip_address
        elsif transport_address_location == :public_ip
          server.public_ip_address
        elsif !server.public_ip_address && server.private_ip_address
          Chef::Log.warn("Server #{machine_spec.name} has no public floating_ip address.  Using private floating_ip '#{server.private_ip_address}'.  Set driver option 'transport_address_location' => :private_ip if this will always be the case ...")
          server.private_ip_address
        elsif server.public_ip_address
          server.public_ip_address
        else
          raise "Server #{server.id} has no private or public IP address!"
          # raise "Invalid 'transport_address_location'.  They can only be 'public_ip', 'private_ip', or 'ip_addresses'."
        end
      end

    end
  end
end
end
end
