require "chef/provisioning"

# Using Fog's default credential storage
with_driver "fog:Scaleway:my-org-uuid:region"

# # Providing the credentials here (from a secure databag?)
# with_driver "fog:Scaleway", compute_options: {
#               scalewat_token: 'your-api-token',
#             }

add_machine_options bootstrap_options: {
  # Images UUID can be obtained with the 'scw' tool.
  # Ex: `scw images`, `scw inspect Debian_Sid` and `scw inspect 100a9904`
  image: "599b736c-48b5-4530-9764-f04d06ecadc7", # Debian Sid / arm
  commercial_type: "C1", # VC1S, ...

  # The private key to use to connect and setup shef
  # key_name: 'id_rsa',
  # or directly the key path
  # key_path: '/etc/chef/mykey.pem',
  # More here: https://github.com/chef/chef-provisioning#machine-options
}

machine "myserver" do
  recipe "apt"
  add_machine_options bootstrap_options: {
    tags: ["forever_up"]
  }
end
