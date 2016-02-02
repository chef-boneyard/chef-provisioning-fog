require 'chef/provisioning'

with_machine_options({
                       :bootstrap_options => {
                         :flavor_ref  => 3,
                         :image_ref => 'my-fake-ubuntu-image-0c1f2c38432b',
                         :nics => [{ :net_id => 'my-tenantnetwork-id-89afddb9db6c'}],
                         :key_name => 'mykeyname',
                         :floating_ip_pool => 'ext-net'
                         },
                       :ssh_username => 'ubuntu'
                     })

machine_batch 'dev' do
  1.upto(3) do |n|
    instance = "#{name}-webserver-#{n}"
    machine instance do
      role 'webserver'
      tag "#{name}-webserver-#{n}"
      converge true
    end
  end
end

machine 'qa-webserver' do
  tag 'qabox'
  machine_options({
                    bootstrap_options: {
                      :flavor_ref  => 3,
                      :nics => [{ :net_id => 'my-tenantnetwork-id-89afddb9db6c'}],
                      :key_name => 'jdizzle',
                      :image_ref => 'my-centos-image-2b0b6bb7b0c12b0b6bb7b0c1',
                      :floating_ip_pool => 'ext-net'
                      },
                    :ssh_username => 'centos'
                  })
  role 'webserver'
  converge true
end
