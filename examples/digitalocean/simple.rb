require "chef/provisioning"
require "chef/provisioning/fog_driver/recipe_dsl"

with_driver "fog:DigitalOcean"

# It is important that this name be the same on the client and on digitalocean
# If the key does not exist in one of 'private_key_paths' it will be created
fog_key_pair "my-simple-key"

add_machine_options :bootstrap_options => {
  :image_distribution => "Ubuntu",
  :image_name => "12.04.5 x64",
  :flavor_name => "1GB",
  :region_name => "London 1",
  :key_name => "my-simple-key"
}

machine "mysimpleserver" do
  recipe 'somerecipe'
end
