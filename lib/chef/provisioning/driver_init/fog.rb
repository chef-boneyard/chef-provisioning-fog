require 'chef/provisioning/fog_driver'

Chef::Provisioning.register_driver_class("fog", Chef::Provisioning::FogDriver::FogDriver)
