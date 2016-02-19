require 'chef/provisioning'
require 'chef/provisioning/fog_driver/recipe_dsl'

# create/update a keypair at Rackspace's API endpoint, so we can use it later
fog_key_pair 'example_id_rsa'

# Options to bootstrap 2gb General instance with CentOS 6 (PVHVM)
with_machine_options({
  :bootstrap_options => {
    :flavor_id => 'general1-2', # required
    :image_id  => 'fabe045f-43f8-4991-9e6c-5cabd617538c', # required
    :key_name  => 'example_id_rsa',

    # optional attributes:
    #   :disk_config, :metadata, :personality, :config_drive,
    #   :boot_volume_id, :boot_image_id
    #
    # ** :image_id must be "" if :boot_volume_id or :boot_image_id is provided
  }
})

machine 'mario' do
  tag 'itsa_me'
  converge true
end
