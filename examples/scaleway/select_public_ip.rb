require "chef/provisioning"

# Using Fog's default credential storage
with_driver "fog:Scaleway:my-org-uuid:ams1"

add_machine_options bootstrap_options: {
                      image: '3b522e7a-8468-4577-ab3e-2b9535384bb8', # Debian Sid / arm
                      commercial_type: "VC1S",
                    }

machine "force_specific_address" do
  recipe 'apt'
  add_machine_options: {
    name: 'another_server_name',
    dynamic_ip_required: false,
    # Must exist in your reserved IPs and be available
    floating_ip: '1.2.3.4',
  }
end

machine "grab_from_pool" do
  recipe 'apt'
  add_machine_options: {
    dynamic_ip_required: false,
    floating_ip_pool: 'global',
  }
end
