require 'chef/provider/lwrp_base'
require 'openssl'
require 'chef/provisioning/chef_provider_action_handler'
require 'chef/provisioning/chef_managed_entry_store'

class Chef
class Provider
class ScalewayVolume < Chef::Provider::LWRPBase
  provides :scaleway_volume

  def action_handler
    @action_handler ||= Chef::Provisioning::ChefProviderActionHandler.new(self)
  end

  def load_current_resource
  end

  def whyrun_supported?
    true
  end

  def volume_spec
    @volume_spec ||= chef_managed_entry_store.get_or_new(:volume, new_resource.name)
  end

  # Get the driver specified in the resource
  def new_driver
    @new_driver ||= run_context.chef_provisioning.driver_for(new_resource.driver)
  end

  def chef_managed_entry_store
    @chef_managed_entry_store ||= Provisioning.chef_managed_entry_store(new_resource.chef_server)
  end


  action :create do
    unless volume_spec.reference && new_driver.volume_for(volume_spec)
      new_driver.create_volume(action_handler, volume_spec,
                               new_resource.volume_options)
    end
    new_resource.id = volume_spec.reference['id']
  end

  action :destroy do
    if volume_spec.reference && volume_spec.reference['id']
      new_driver.destroy_volume(action_handler, volume_spec,
                                new_resource.volume_options)
      volume_spec.delete(action_handler)
    end
  end
end
end
end
