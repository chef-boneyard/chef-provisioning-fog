class Chef
  module Provisioning
    module FogDriver
      module Providers
        class TestDriver < FogDriver::Driver
          Driver.register_provider_class('TestDriver', Chef::Provisioning::FogDriver::Providers::TestDriver)

          attr_reader :config
          def initialize(driver_url, config)
            super
          end

          def self.compute_options_for(provider, id, config)
            [config, 'test']
          end
        end
      end
    end
  end
end
