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

  describe '#private_key_for' do
    let(:machine_spec) { double('machine_spec', reference: {}, name: 'my_machine') }
    let(:machine_options) { { bootstrap_options:  bootstrap_options } }

    context 'when the machine has a key path in bootstrap options' do
      let(:bootstrap_options) { { key_path: '/tmp/test_private_key_file' } }

      it 'reads the key file' do
        allow(IO).to receive(:read).and_return 'test_private_key'
        expect(driver.private_key_for(machine_spec, machine_options, nil)).to eq 'test_private_key'
      end
    end

    context 'when the machine has a key name in bootstrap options' do
      let(:bootstrap_options) { { key_name: 'test_private_key_name' } }

      it 'calls get_private_key' do
        expect(driver).to receive(:get_private_key).with('test_private_key_name').and_return 'test_private_key'
        expect(driver.private_key_for(machine_spec, machine_options, nil)).to eq 'test_private_key'
      end
    end

    context 'when the machine has no bootstrap options' do
      it 'raises an error' do
        expect { driver.private_key_for(machine_spec, {}, nil) }
          .to raise_error(RuntimeError, 'No key found to connect to my_machine ({}) : machine_options -> ({})!')
      end
    end

    context 'when the machine has no key path or key name bootstrap options' do
      let(:bootstrap_options) { {} }

      it 'raises an error' do
        expect { driver.private_key_for(machine_spec, machine_options, nil) }.to raise_error(
          RuntimeError, 'No key found to connect to my_machine ({}) : machine_options -> ({:bootstrap_options=>{}})!')
      end
    end
  end
end
