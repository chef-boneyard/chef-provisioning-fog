require 'chef/provisioning'

with_machine_options({
  :bootstrap_options => {
    :image_name => 'my-ubuntu-image-id',
    :zone_name => 'europe-west1-d',
    :machine_type => 'n1-standard-1'
  }
})

machine "my_server" do
  recipe "pretty_recipe"
end
