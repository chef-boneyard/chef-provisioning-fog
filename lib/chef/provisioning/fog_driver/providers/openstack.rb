# fog:OpenStack:https://identifyhost:portNumber/v2.0
require 'byebug'
class Chef
module Provisioning
module FogDriver
  module Providers
    class OpenStack < FogDriver::Driver

      Driver.register_provider_class('OpenStack', FogDriver::Providers::OpenStack)

      def creator
        compute_options[:openstack_username]
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

      # Image methods
      def allocate_image(action_handler, image_spec, image_options, machine_spec, machine_options)
        byebug
        actual_image = image_for(image_spec)
        aws_tags = image_options.delete(:aws_tags) || {}
        if actual_image.nil? || !actual_image.exists? || actual_image.state == :failed
          action_handler.perform_action "Create image #{image_spec.name} from machine #{machine_spec.name} with options #{image_options.inspect}" do
            image_options[:name] ||= image_spec.name
            image_options[:instance_id] ||= machine_spec.reference['instance_id']
            image_options[:description] ||= "Image #{image_spec.name} created from machine #{machine_spec.name}"
            Chef::Log.debug "AWS Image options: #{image_options.inspect}"
            actual_image = ec2.images.create(image_options.to_hash)
            image_spec.reference = {
              'driver_version' => Chef::Provisioning::AWSDriver::VERSION,
              'image_id' => actual_image.id,
              'allocated_at' => Time.now.to_i
            }
            image_spec.driver_url = driver_url
          end
        end
        aws_tags['From-Instance'] = image_options[:instance_id] if image_options[:instance_id]
        converge_tags(actual_image, aws_tags, action_handler)
      end

      def ready_image(action_handler, image_spec, image_options)
        byebug
        actual_image = image_for(image_spec)
        if actual_image.nil? || !actual_image.exists?
          raise 'Cannot ready an image that does not exist'
        else
          if actual_image.state != :available
            action_handler.report_progress 'Waiting for image to be ready ...'
            wait_until_ready_image(action_handler, image_spec, actual_image)
          else
            action_handler.report_progress "Image #{image_spec.name} is ready!"
          end
        end
      end

      def destroy_image(action_handler, image_spec, image_options)
        byebug
        # TODO the driver should automatically be set by `inline_resource`
        d = self
        Provisioning.inline_resource(action_handler) do
          aws_image image_spec.name do
            action :destroy
            driver d
          end
        end
      end

      def wait_until_ready_image(action_handler, image_spec, image=nil)
        wait_until_image(action_handler, image_spec, image) { image.state == :available }
      end

      def wait_until_image(action_handler, image_spec, image=nil, &block)
        image ||= image_for(image_spec)
        time_elapsed = 0
        sleep_time = 10
        max_wait_time = 300
        if !yield(image)
          action_handler.report_progress "waiting for #{image_spec.name} (#{image.id} on #{driver_url}) to be ready ..."
          while time_elapsed < max_wait_time && !yield(image)
           action_handler.report_progress "been waiting #{time_elapsed}/#{max_wait_time} -- sleeping #{sleep_time} seconds for #{image_spec.name} (#{image.id} on #{driver_url}) to be ready ..."
           sleep(sleep_time)
           time_elapsed += sleep_time
          end
          unless yield(image)
            raise "Image #{image.id} did not become ready within #{max_wait_time} seconds"
          end
          action_handler.report_progress "Image #{image_spec.name} is now ready"
        end
      end

      def image_for(image_spec)
        byebug
        Chef::Resource::AwsImage.get_aws_object(image_spec.name, driver: self, managed_entry_store: image_spec.managed_entry_store, required: false)
      end

    end
  end
end
end
end
