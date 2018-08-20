require "chef/provisioning"
require "chef/provisioning/fog_driver/recipe_dsl"

with_driver "fog:XenServer:X.Y.W.Z", compute_options: {
  xenserver_username: "user",
  xenserver_password: "password",
  xenserver_defaults: {
    "template" => "ubuntu-14.04"
  }
}

machine "ubuntu-chef" do
  machine_options(
    ssh_username: "ssh_user",
    ssh_password: "ssh_password",
    ssh_options: {
      timeout: 120
    },
    bootstrap_options: {
      memory: "4096",
      cpus: 4,
      network: {
        vifs: ["eth0"],
        vm_ip: "10.10.10.100",
        vm_netmask: "255.255.255.0",
        vm_gateway: "10.10.10.1",
        vm_dns: "8.8.4.4",
        vm_domain: "example.net"
      },
      additional_disks: {
        ubuntu_additional_disk: {
          size: 10, # Expressed in GB
          description: "Disk description",
          sr: "sr-name"
        }
      }
    }
  )
end
