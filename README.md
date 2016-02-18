# chef-provisioning-fog

[![Gem Version](https://img.shields.io/gem/v/chef-provisioning-fog.svg)][gem]
[![Build Status](https://travis-ci.org/chef/chef-provisioning-fog.svg?branch=master)][travis]
[![Dependency Status](https://img.shields.io/gemnasium/chef/chef-provisioning-fog.svg)][gemnasium]

This is the Fog driver for Chef Provisioning.  It provides Amazon EC2, Rackspace, DigitalOcean, SoftLayer, OpenStack, vCloud Air and XenServer functionality.

## Documentation

These are the primary documents to help learn about using Provisioning and creating Provisioning drivers:

* [Chef Docs](https://docs.chef.io/provisioning.html)
* [Frequently Asked Questions](https://github.com/chef/chef-provisioning/blob/master/docs/faq.md)
* [Configuration](https://github.com/chef/chef-provisioning/blob/master/docs/configuration.md#configuring-and-using-provisioning-drivers)
* [Writing Drivers](https://github.com/chef/chef-provisioning/blob/master/docs/building_drivers.md#writing-drivers)
* [Embedding](https://github.com/chef/chef-provisioning/blob/master/docs/embedding.md)
* [Providers](https://github.com/chef/chef-provisioning/blob/master/docs/providers)

## chef-provisioning-fog Usage and Examples

**A note about key pairs** - The key name used in `fog_key_pair` must be the same as the filename of the local key to be used. If the key does not exist in one of `private_key_paths` (which you can set in `knife.rb` or in a `client.rb`) it will be created.

### DigitalOcean

Update your knife.rb to contain your DigitalOcean API token and the driver

```ruby
driver 'fog:DigitalOcean'
driver_options compute_options: { digitalocean_token: 'token' }
```

For a full example see [examples/digitalocean/simple.rb](examples/digitalocean/simple.rb).

### OpenStack

You'll need to update your `knife.rb` to work with this also:

```ruby
driver 'fog:OpenStack'
driver_options :compute_options => { :openstack_auth_url => 'http://YOUROPENSTACK-CLOUD:5000/v2.0/tokens',
                                     :openstack_username => 'YOURUSERNAME',
                                     :openstack_api_key  => 'YOURPASSWORD',
                                     :openstack_tenant   => 'YOURTENANTIDNAME' }
```

For a full example see [examples/openstack/simple.rb](examples/openstack/simple.rb).

### Rackspace

For this example, you must configure `knife.rb` with your credentials and a region to operate on. This example is [also available as a Github repo](https://github.com/martinb3/chef-provisioning-rackspace-example).

You must configure some credentials and region in a `knife.rb` file like so:
```ruby
driver 'fog:Rackspace'
driver_options :compute_options => {
                                     :rackspace_username => 'my_rackspace_user',
                                     :rackspace_api_key  => 'api_key_for_user',
                                     :rackspace_region => 'dfw' # could be 'org', 'iad', 'hkg', etc  }
```

For a full example see [examples/rackspace/simple.rb](examples/rackspace/simple.rb).

### Google Compute Engine

You'll need to update your `knife.rb` to work with this also:

```ruby
driver 'fog:Google'
driver_options :compute_options => { :provider => 'google',
                                     :google_project => 'YOUR-PROJECT-ID', # the name will work here
                                     :google_client_email => 'YOUR-SERVICE-ACCOUNT-EMAIL',
                                     :google_key_location => 'YOUR-SERVICE-P12-KEY-FILE-FULL-PATH-.p12' }

```

In order to get the `YOUR-SERVICE-P12-KEY-FILE.p12` you need to set up a Service account. This is located at `Home > Permissions > Service Accounts` and you'll need to create a new one to get a new key. After that place it some place such as `~/.chef/` so chef-provisioning-fog can find it. Your `google_client_email` would be something like: `<UNIQUE_NAME>@<PROJECT>.iam.gserviceaccount.com`.

For a full example see [examples/google/simple.rb](examples/google/simple.rb).

### Cleaning up

```ruby
require 'chef/provisioning'

machine_batch do
  machines search(:node, '*:*').map { |n| n.name }
  action :destroy
end
```

When you are done with the examples, run this to clean up:

```
$ chef-client -z destroy_all.rb
```

## What Is Chef Provisioning?

Chef Provisioning has two major abstractions: the machine resource, and drivers.

### The `machine` resource

You declare what your machines do (recipes, tags, etc.) with the `machine` resource, the fundamental unit of Chef Provisioning.  You will typically declare `machine` resources in a separate, OS/provisioning-independent file that declares the *topology* of your app--your machines and the recipes that will run on them.

The machine resources from the [cluster.rb example](https://github.com/chef/chef-provisioning/blob/master/docs/examples/cluster.rb) are pretty straightforward.  Here's a copy/paste:

```ruby
# Database!
machine 'mario' do
  recipe 'postgresql'
  recipe 'mydb'
  tag 'mydb_master'
end

num_webservers = 1

# Web servers!
1.upto(num_webservers) do |i|
  machine "luigi#{i}" do
    recipe 'apache'
    recipe 'mywebapp'
  end
end
```

You will notice the dynamic nature of the number of web servers.  It's all code, your imagination is the limit :)

### Drivers

Drivers handle the real work of getting those abstract definitions into real, physical form.  They handle the following tasks, idempotently (you can run the resource again and again and it will only create the machine once--though it may notice things are wrong and fix them!):

* Acquiring machines from the cloud, creating containers or VMs, or grabbing bare metal
* Connecting to those machines via ssh, winrm, or other transports
* Bootstrapping chef onto the machines and converging the recipes you suggested

The driver API is separated out so that new drivers can be made with minimal effort (without having to rewrite ssh, tunneling, bootstrapping, and OS support).  But to the user, they appear as a single thing, so that the machine acquisition can use its smarts to autodetect the other bits (transports, OS's, etc.).

Drivers save their data in the Chef node itself, so that they will be accessible to everyone who is using the Chef server to manage the nodes.

### Tuning Timeouts

`chef-provisioning-fog` interacts with your cloud provider's endpoint.  Most of
the time, default timeouts for the following would be sufficient.

#### Fog `connection_options`

Modify the defaults if your Fog endpoint takes awhile to send/receive API requests.  Normally, if you see `Excon` timeouts you should tune these [parameters](https://github.com/excon/excon/blob/75d85a7e304cbd1c9dc3c7c40c6de5a995f5cd04/lib/excon/constants.rb#L110-L139).

```ruby
with_driver 'fog:foo',
  :compute_options => {
    :connection_options => {
      # set connection to persist (default is false)
      :persistent => true,
      # set longer connect_timeout (default is 60 seconds)
      :connect_timeout => 360,
      # set longer read_timeout (default is 60 seconds)
      :read_timeout => 360,
      # set longer write_timeout (default is 60 seconds)
      :write_timeout => 360,
    }
  }
```
#### `machine_option` timeouts

Modify these timeouts if you need Chef to wait a bit of time to allow for the machine to be ready.

```ruby
with_machine_options({
  # set longer to wait for the instance to boot to ssh (defaults to 180)
  :create_timeout => 360,
  # set longer to wait for the instance to start (defaults to 180)
  :start_timeout => 360,
  # set longer to wait for ssh to be available if the instance is detected up (defaults to 20)
  :ssh_timeout => 360
})
```

#### Chef Client `convergence_options`

Modify this if your chef client convergences take awhile.

```ruby
with_machine_options({
  :convergence_options => {
    # set longer if you need more time to converge (default: 2 hours)
    :chef_client_timeout => 120*60
  }
})
```

[gem]: https://rubygems.org/gems/chef-provisioning-fog
[travis]: https://travis-ci.org/chef/chef-provisioning-fog
[gemnasium]: https://gemnasium.com/chef/chef-provisioning-fog
