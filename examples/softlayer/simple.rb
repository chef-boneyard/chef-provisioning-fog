todo = node['action'] || :converge
force_converge = node['converge'] || false

chef_role 'all' do
    recipe 'ntp'
end

chef_environment 'softlayer' do
    default_attributes :ntp => {
        :servers => [
            "time.service.softlayer.com"
        ]
    }
end

with_chef_environment 'softlayer'


common_options = {
    :bootstrap_options => {
        :hourly_billing_flag => true,
        :create_timeout => 3600,
        :start_timeout => 300,
        :datacenter => 'sjc01',
        :domain => 'example.com',
        # :key_name is looked up by_label; make sure you have a public key created
        # on control portal at https://control.softlayer.com/devices/sshkeys with a
        # matching Label.
        :key_name => 'key.label',
    },
}

with_machine_options common_options

machine_batch "SoftLayer Servers" do
    action todo

    add_machine_options :bootstrap_options => {:flavor_id => 'm1.tiny'}

    machine "centos5" do
        converge force_converge
        add_machine_options :bootstrap_options => { :os_code => 'CENTOS_5_64' }
        role 'all'
    end

    machine "centos6" do
        converge force_converge
        add_machine_options :bootstrap_options => { :os_code => 'CENTOS_6_64' }
        role 'all'
    end

    machine "debian7" do
        converge force_converge
        add_machine_options :bootstrap_options => { :os_code => 'DEBIAN_7_64' }
        role 'all'
    end

    machine "ubuntu14" do
        converge force_converge
        add_machine_options :bootstrap_options => { :os_code => 'UBUNTU_14_64' }
        role 'all'
    end

    machine "centos6.bm" do
        # I completely override the machine_options here because :flavor_id
        # will get picked up in deep merge and add options that conflict
        # with :fixed_configuration_preset.
        machine_options common_options

        add_machine_options :bootstrap_options => {
            :fixed_configuration_preset => 'S1270_8GB_2X1TBSATA_NORAID',
            :create_timeout => 3600 * 4,
            :os_code => 'CENTOS_6_64',
        }
        converge force_converge
        role 'all'
    end
end
