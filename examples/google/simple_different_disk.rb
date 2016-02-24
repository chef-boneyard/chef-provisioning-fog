require 'chef/provisioning'

with_machine_options({
                       :bootstrap_options => {
                         :image_name => 'my-ubuntu-image-id',
                         :zone_name => 'europe-west1-d',
                         :machine_type => 'n1-standard-1',
                         :key_name => 'id_rsa',  # this is the local name of your SSH private key.
                         # You'll need to set up your ssh-key via: Home > Compute Engine > Metadata > SSH Keys and upload your public key
                         :disk_type => 'pd-ssd'
                         # disktypes are multiple, check the backend you want to use, it defaults to 'pd-standard' though
                       },
                       :ssh_username => 'YOURUSERNAME'
                     })

machine "myserver" do
  recipe "apt"
end
