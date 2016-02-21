require 'chef/provisioning'

with_machine_options({
                       :bootstrap_options => {
                         :package => "t4-standard-128M", # small package for testing
                         :image => "5917ca96-c888-11e5-8da0-e785a1ad1185", # Ubuntu's 14.04 infrastructure image
                         :key_name => "KEY-NAME" # Your public key name
                       },
                     })

machine "myserver" do
  tag 'tagtag'
end
