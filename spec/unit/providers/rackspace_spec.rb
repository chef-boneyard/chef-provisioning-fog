require 'chef/provisioning/fog_driver'
require 'chef/provisioning/fog_driver/providers/rackspace'

describe Chef::Provisioning::FogDriver::Providers::Rackspace do
  subject { Chef::Provisioning::FogDriver.from_provider('Rackspace',{}) }

  it "returns the correct driver" do
    expect(subject).to be_an_instance_of Chef::Provisioning::FogDriver::Providers::Rackspace
  end

  it "has a FOG backend" do
    pending unless Fog.mock?
    expect(subject.compute).to be_an_instance_of Fog::Compute::RackspaceV2::Mock
  end

end
