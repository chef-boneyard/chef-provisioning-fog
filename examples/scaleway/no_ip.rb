require "chef/provisioning"

# Using Fog's default credential storage
with_driver "fog:Scaleway:my-org-uuid:par1"

add_machine_options bootstrap_options: {
  image: '3b522e7a-8468-4577-ab3e-2b9535384bb8', # Debian Sid / arm
  commercial_type: "VC1S",
}

machine "no_ipv4" do
  recipe 'apt'
  add_machine_options: {
    dynamic_ip_required: false,
    enable_ipv6: true,
  }
end
