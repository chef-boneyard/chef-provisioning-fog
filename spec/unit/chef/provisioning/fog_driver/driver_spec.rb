require 'chef/provisioning/fog_driver/driver'

describe Chef::Provisioning::FogDriver::Driver do
  let(:driver) { Chef::Provisioning::FogDriver::Driver.new("fog:OpenStack", {}) }

  before(:each) do
    Chef::Provisioning::FogDriver::Driver.send(:public, *Chef::Provisioning::FogDriver::Driver.protected_instance_methods)
  end

  describe "#determine_remote_host" do
    let(:machine_spec) { double("machine_spec", :reference => reference, :name => 'name') }
    let(:server) { double("server", :private_ip_address => 'private', :public_ip_address => 'public', :ip_addresses => ['first_ip_address'])}

    context "when 'use_private_ip_for_ssh' is specified in the machine_spec.reference" do
      let(:reference) { { 'use_private_ip_for_ssh' => true } }
      it "returns the private ip" do
        expect(driver.determine_remote_host(machine_spec, server)).to eq('private')
        expect(reference).to eq( {'transport_address_location' => :private_ip} )
      end
    end

    context "when 'transport_address_location' is set to :private_ip" do
      let(:reference) { { 'transport_address_location' => :private_ip } }
      it "returns the private ip" do
        expect(driver.determine_remote_host(machine_spec, server)).to eq('private')
      end
    end

    context "when 'transport_address_location' is set to :ip_addresses" do
      let(:reference) { { 'transport_address_location' => :ip_addresses } }
      it "returns the first ip_address from array" do
        expect(driver.determine_remote_host(machine_spec, server)).to eq('first_ip_address')
      end
    end

    context "when 'transport_address_location' is set to :public_ip" do
      let(:reference) { { 'transport_address_location' => :public_ip } }
      it "returns the public ip" do
        expect(driver.determine_remote_host(machine_spec, server)).to eq('public')
      end
    end

    context "when machine_spec.reference does not specify the transport type" do
      let(:reference) { Hash.new }

      context "when the machine does not have a public_ip_address" do
        let(:server) { double("server", :private_ip_address => 'private', :public_ip_address => nil, :ip_addresses => ['first_ip_address'])}

        it "returns the private ip" do
          expect(driver.determine_remote_host(machine_spec, server)).to eq('private')
        end
      end

      context "when the machine has a public_ip_address" do
        let(:server) { double("server", :private_ip_address => 'private', :public_ip_address => 'public', :ip_addresses => ['first_ip_address'])}

        it "returns the public ip" do
          expect(driver.determine_remote_host(machine_spec, server)).to eq('public')
        end
      end

      context "when the machine does not have a public_ip_address or private_ip_address" do
        let(:server) { double("server", :private_ip_address => nil, :public_ip_address => nil, :ip_addresses => ['first_ip_address'], :id => 'id')}

        it "raises an error" do
          expect {driver.determine_remote_host(machine_spec, server)}.to raise_error("Server #{server.id} has no private or public IP address!")
        end
      end
    end
  end
end
