require 'spec_helper'
require 'chef/provisioning/fog_driver/providers/testdriver'

describe Chef::Provisioning::FogDriver do

  describe ".from_url" do
    subject { Chef::Provisioning::FogDriver::Driver.from_provider('TestDriver', {}) }

    it "should return the correct class" do
      expect(subject).to be_an_instance_of Chef::Provisioning::FogDriver::Providers::TestDriver
    end

    it "should call the target compute_options_for" do
      expect(Chef::Provisioning::FogDriver::Providers::TestDriver).to receive(:compute_options_for)
        .with('TestDriver', anything, {}).and_return([{}, 'test']).twice
      subject
    end

  end

  describe "when creating a new class" do
    it "should return the correct class" do
      test = Chef::Provisioning::FogDriver::Driver.new('fog:TestDriver:foo', {})
      expect(test).to be_an_instance_of Chef::Provisioning::FogDriver::Providers::TestDriver
    end

    it "should populate config" do
      test = Chef::Provisioning::FogDriver::Driver.new('fog:TestDriver:foo', {test: "chef_provisioning"})
      expect(test.config[:test]).to eq "chef_provisioning"
    end
  end
end
