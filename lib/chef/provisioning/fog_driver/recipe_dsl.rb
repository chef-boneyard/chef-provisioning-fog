require 'chef/provisioning/fog_driver/driver'
require 'chef/resource/fog_key_pair'
require 'chef/provider/fog_key_pair'
require 'chef/resource/scaleway_volume'
require 'chef/provider/scaleway_volume'

class Chef
  module DSL
    module Recipe
      def with_fog_driver(provider, driver_options = nil, &block)
        config = Cheffish::MergedConfig.new({ :driver_options => driver_options }, run_context.config)
        driver = Driver.from_provider(provider, config)
        run_context.chef_provisioning.with_driver(driver, &block)
      end

      def with_fog_ec2_driver(driver_options = nil, &block)
        with_fog_driver('AWS', driver_options, &block)
      end

      def with_fog_openstack_driver(driver_options = nil, &block)
        with_fog_driver('OpenStack', driver_options, &block)
      end

      def with_fog_rackspace_driver(driver_options = nil, &block)
        with_fog_driver('Rackspace', driver_options, &block)
      end

      def with_fog_vcair_driver(driver_options = nil, &block)
        with_fog_driver('vcair', driver_options, &block)
      end

      def with_fog_scaleway_driver(driver_options = nil, &block)
        with_fog_driver('Scaleway', driver_options, &block)
      end

    end
  end
end
