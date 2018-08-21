require "chef/provisioning"
require "chef/provisioning/fog_driver/recipe_dsl"

with_driver("fog:Scaleway:7d1f7463-ffef-4669-ae1e-dfdbb1c50575:par1")

scaleway_volume "test-volume4" do
  volume_options volume_type: "l_ssd", size: 50_000_000_000
end

machine "machine_with_extra_volume" do
  add_machine_options bootstrap_options: {
    commercial_type: "C1",
    image: "eeb73cbf-78a9-4481-9e38-9aaadaf8e0c9",
    dynamic_ip_required: false,
    volumes: {
      1 => { name: "test-volume4" }
    }
  }
end
