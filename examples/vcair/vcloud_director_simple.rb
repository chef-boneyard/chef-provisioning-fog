require 'chef/provisioning'

etc_hosts_local = "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4\n"

with_driver 'fog:vcair:myvcair.mycorp.com' do
  with_machine_options(
    bootstrap_options: {
      image_name: 'chef-12.17.44',
      vdc: 'myVDC',
      net: 'myVDC_NET',
      memory: '1536',
      cpus: '2',
      create_timeout: 300,
      start_timeout: 300,
      key_name: 'id_rsa'
    },
    ssh_username: 'sudo-admin',
    ssh_options: {
      timeout: 30,
      auth_methods: ['publickey']
    },
    convergence_options: {
      ssl_verify_mode: :verify_none,
      chef_version: '12.17.44'
    },
    sudo: true
  )

  # First, we'll create all the VMs we need
  machine_batch 'apache cluster create' do
    1.upto(2) do |i|
      machine "apache-#{i}" do
        chef_environment '_default'
      end
    end
    action :ready
    retries 1
  end

  machine_batch 'redis cluster create' do
    1.upto(3) do |i|
      machine "redis-#{i}" do
        chef_environment '_default'
      end
    end
    action :ready
  end


  # Now we'll upload a new /etc/hosts to each of the VMs so they know about the others
  ruby_block 'search for all the VMs' do
    block do
      running_vms = search(
        :node,"name:*",
        filter_result: { 'ipaddress' => ['ipaddress'], 'hostname' => ['hostname'], 'fqdn' => ['fqdn'] }
      )
      Chef::Log.info("Running VMs: #{running_vms}")
      running_vms.each do |result|
        etc_hosts_local << "#{result['ipaddress']} #{result['fqdn']} #{result['hostname']}\n"
      end
    end
  end

  log 'log the contents of generated /etc/hosts' do
    message lazy { "/etc/hosts:\n#{etc_hosts_local}"}
    level :info
  end

  1.upto(2) do |i|
    machine_file '/etc/hosts' do
      machine "apache-#{i}"
      content lazy { etc_hosts_local }
      action :upload
    end
  end

  1.upto(3) do |i|
    machine_file '/etc/hosts' do
      machine "redis-#{i}"
      content lazy { etc_hosts_local }
      action :upload
    end
  end
end
