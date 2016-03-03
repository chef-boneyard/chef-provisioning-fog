require 'spec_helper'
require 'chef/provisioning/fog_driver/providers/softlayer'

describe Chef::Provisioning::FogDriver::Providers::SoftLayer do
  subject do
    Chef::Provisioning::FogDriver::Driver.from_provider(
      'SoftLayer',
        driver_options: {
          compute_options: {
              softlayer_username: 'test_username', softlayer_api_key: 'test_api_key'}
      }
    )
  end

  it "returns the correct driver" do
    expect(subject).to be_an_instance_of Chef::Provisioning::FogDriver::Providers::SoftLayer
  end

  it "has a Fog backend" do
    pending unless Fog.mock?
    expect(subject.compute).to be_an_instance_of Fog::Compute::Softlayer::Mock
  end
end

