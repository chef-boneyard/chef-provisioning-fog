require 'chef/provisioning'

# These are the options you can use: http://docs.aws.amazon.com/sdkforruby/api/Aws/EC2/Client.html#run_instances-instance_method


 add_machine_options bootstrap_options: {
                       key_name: 'THE-KEY-IN-EC2-Network & Security-Key Pairs-Name'
                       flavor_id: 'm1.medium',
                       image_id: 'ami-f1ce8bc1', # this is ubuntu 14.04.1
                       security_group_ids: "sg-xxxxxxxx"
 }

machine 'bowser' do
  tag 'loadbalancer'
end
