require 'spec_helper'
require 'chef/provisioning/fog_driver/providers/scaleway'

describe Chef::Provisioning::FogDriver::Providers::Scaleway do
  subject do
    Chef::Provisioning::FogDriver::Driver.from_provider(
      'Scaleway', driver_options: { compute_options: {
                                      scaleway_organization: 'org',
                                      scaleway_token: 'key'}
                                   }
    )
  end

  it "returns the correct driver" do
    expect(subject).to be_an_instance_of Chef::Provisioning::FogDriver::Providers::Scaleway
  end

  it "has a Fog backend" do
    pending unless Fog.mock?
    expect(subject.compute).to be_an_instance_of Fog::Scaleway::Compute::Mock
  end

  describe '#creator' do
    it 'returns the organization' do
      expect(subject.creator).to eq 'org'
    end
  end
end
