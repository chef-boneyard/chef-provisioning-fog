require "chef/provisioning"

class Chef::Resource::ScalewayVolume < Chef::Resource::LWRPBase
  self.resource_name = "scaleway_volume"

  def initialize(*args)
    super
    @driver = run_context.chef_provisioning.current_driver
    @chef_server = run_context.cheffish.current_chef_server
  end

  actions :create, :destroy, :nothing
  default_action :create

  attribute :id
  attribute :chef_server
  attribute :driver
  attribute :volume_options

  def add_volume_options(options)
    @volume_options = if @volume_options
                        Cheffish::MergedConfig.new(options, @volume_options)
                      else
                        options
                      end
  end

  # We are not interested in Chef's cloning behavior here.
  def load_prior_resource(*_args)
    Chef::Log.debug("Overloading #{resource_name}.load_prior_resource with NOOP")
  end
end
