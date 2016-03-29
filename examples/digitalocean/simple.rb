require "chef/provisioning"
require "chef/provisioning/fog_driver/recipe_dsl"

with_driver "fog:DigitalOcean"

add_machine_options :bootstrap_options => {
  :image_distribution => "Ubuntu",
  :image_name => "14.04.4 x64",
  :flavor_name => "2GB",
  :region_name => "London 1",
  :key_name => "my-simple-key-name-already-on-DO"
}

machine "mysimpleserver" do
  recipe 'somerecipe'
  tag 'tagtagtag'
end
