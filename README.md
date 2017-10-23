# chef-provisioning-fog

[![Gem Version](https://img.shields.io/gem/v/chef-provisioning-fog.svg)][gem]
[![Build Status](https://travis-ci.org/chef/chef-provisioning-fog.svg?branch=master)][travis]
[![Dependency Status](https://img.shields.io/gemnasium/chef/chef-provisioning-fog.svg)][gemnasium]

This is the Fog driver for Chef Provisioning.  It provides Amazon EC2, DigitalOcean, Google Compute Engine, IBM Softlayer, Joyent, OpenStack, Rackspace, vCloud Air and XenServer functionality.

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

### Amazon EC2

NOTE: Using chef-provisioning-fog for AWS is discouraged and new users should use `chef-provisioning-aws`.  To use chef-provisioning-fog the `fog-aws` gem must be installed
by hand (it is not list a dependency of this gem any more).  ChefDK users should `chef gem install fog-aws`.


You'll need to update your `knife.rb` to work:

You need one of the following for the driver:
```
fog:AWS:<account_id>:<region>
fog:AWS:<profile_name>
fog:AWS:<profile_name>:<region>
```

For example:

```ruby
driver 'fog:AWS:<account_id>:<region>'
driver_options :compute_options => {
                                     :aws_access_key_id => 'YOUR-ACCESS-KEY-ID',
                                     :aws_secret_access_key => 'YOUR-SECRET-ACCESS-KEY',
                                     :region => 'THE-REGION-YOU-WANT-TO-PROVISION-IN'
                                    }
```

For a full example see [examples/aws/simple.rb](examples/aws/simple.rb).


### DigitalOcean

Update your `knife.rb` to contain your DigitalOcean API token and the driver:

```ruby
driver 'fog:DigitalOcean'
driver_options :compute_options => {
                                    :digitalocean_token => 'token'
                                   }
```

[fog](http://fog.io) 1.38.0 (Newest release) has an issue with DigitalOcean. If
you want to use DigitalOcean and `chef-provisioning-fog` you need to down grade
your fog gem.

```shell
$ gem install fog --version 1.37.0
Successfully installed fog-1.37.0
Parsing documentation for fog-1.37.0
$ gem uninstall fog

Select gem to uninstall:
 1. fog-1.37.0
 2. fog-1.38.0
 3. All versions
> 2
Successfully uninstalled fog-1.38.0
$
```

For a full example see [examples/digitalocean/simple.rb](examples/digitalocean/simple.rb).

### Google Compute Engine

NOTE: currently `fog-google` is broken against the current `google-api-client` client.  The dependency on fog-google has
been removed until this is fixed upstream.  Users will likely need to use a Gemfile and pin manually to a working version
of fog, fog-google and google-api-client.  It is unlikely that it will work successfully with ChefDK with no Gemfile

You'll need to update your `knife.rb` to work:

```ruby
driver 'fog:Google'
driver_options :compute_options => {
                                     :provider => 'google',
                                     :google_project => 'YOUR-PROJECT-ID', # the name will work here
                                     :google_client_email => 'YOUR-SERVICE-ACCOUNT-EMAIL',
                                     :google_key_location => 'YOUR-SERVICE-P12-KEY-FILE-FULL-PATH.p12'
                                    }

```

In order to get the `YOUR-SERVICE-P12-KEY-FILE.p12` you need to set up a Service
account. This is located at `Home > Permissions > Service Accounts` and you'll
need to create a new one to get a new key. After that place it some place such
as `~/.chef/` so chef-provisioning-fog can find it. Your `google_client_email`
would be something like: `<UNIQUE_NAME>@<PROJECT>.iam.gserviceaccount.com`.

For a full simple example see [examples/google/simple.rb](examples/google/simple.rb).

For an example that shows a different `:disk_type` see
[examples/google/simple_different_disk.rb](examples/google/simple_different_disk.rb).

### IBM SoftLayer

You'll need to update your `knife.rb` to work with this also:

```ruby
driver 'fog:SoftLayer'
driver_options :compute_options => {
                                     :provider => 'softlayer',
                                     :softlayer_username => 'username',
                                     :softlayer_api_key => 'api_key',
                                     :softlayer_default_domain => 'example.com',
                                   }

```

Once you or your administrator has created a SoftLayer account you can manage
your API key at https://control.softlayer.com/account/users

`:bootstrap_options => {:key_name => 'label'}` is looked up by_label; make sure
you have a public key created on control portal at
https://control.softlayer.com/devices/sshkeys with a matching label.

NOTE: the SoftLayer driver injects a custom post provisioning script that
ensures some packages needed by chef-provisioning-fog to install chef are
present (e.g. sudo). The injected script will call your :postInstallScriptUri
if you define one. The driver will wait until the injected script is done. The
driver and script communicate using userMetadata so you cannot use metadata.

For a full example see [examples/softlayer/simple.rb](examples/softlayer/simple.rb).

### Joyent

You'll need to update your `knife.rb` to work:

```ruby
driver 'fog:Joyent'
driver_options :compute_options => {
                                     :joyent_username => 'YOUR-JOYENT-LOGIN',
                                     :joyent_password => 'YOUR-JOYENT-PASSWORD',
                                     :joyent_keyname => 'THE-SSH-KEY-YOUVE-UPLOADED',
                                     :joyent_version => '7.3.0', # if you are using the joyent public cloud
                                     :joyent_keyfile => 'YOUR-PRIVATE-SSH-KEY-LOCATION' # Such as '/Users/jasghar/.ssh/id_rsa'
                                    }
```

Tested this with the [Joyent Public Cloud](https://docs.joyent.com/public-cloud). For the package names, use the
GUI to find the name(s) that you want to use. This is also required to figure out the Image UUID, there doesn't seem to be an
effective way of doing this without the GUI.

For a more in-depth usage of this driver to use with either Private or Public Joyent cloud, checkout [this blog post][joyent_howto] by mhicks from [#smartos][freenode_smartos] on freenode.

For a infrastructure container example see [examples/joyent/infrastructure.rb](examples/joyent/infrastructure.rb).


### OpenStack

You'll need to update your `knife.rb` to work:

```ruby
driver 'fog:OpenStack'
driver_options :compute_options => {
                                     :openstack_auth_url => 'http://YOUROPENSTACK-CLOUD:5000/v2.0/tokens',
                                     :openstack_username => 'YOUR-USERNAME',
                                     :openstack_api_key  => 'YOUR-PASSWORD',
                                     :openstack_tenant   => 'YOUR-TENANT-ID-NAME'
                                    }
```

For a full example see [examples/openstack/simple.rb](examples/openstack/simple.rb).

### Rackspace

For this example, you must configure `knife.rb` with your credentials and a region to operate on. This example is [also available as a Github repo](https://github.com/martinb3/chef-provisioning-rackspace-example).

You must configure some credentials and region in a `knife.rb` file like so:
```ruby
driver 'fog:Rackspace'
driver_options :compute_options => {
                                     :rackspace_username => 'MY-RACKSPACE-USERr',
                                     :rackspace_api_key  => 'API-KEY-FOR-USER',
                                     :rackspace_region => 'dfw' # could be 'org', 'iad', 'hkg', etc
                                    }
```

For a full example see [examples/rackspace/simple.rb](examples/rackspace/simple.rb).

### vCloud Air

NOTE:  The `fog` mega-gem has been removed as a direct dependency of `chef-provisioning-fog`.  Since support
for vcair is only in the `fog` gem and fog does not supply any "meta-gem" for vcair specifically, that means
that the `fog` gem must be manually installed.  ChefDK users should manually `chef gem install fog`.

Docs TODO.

### XenServer

You should configure XenServer driver with your credentials:

```ruby
with_driver "fog:XenServer:<XEN-SERVER-IP/NAME>", compute_options: {
  xenserver_username: 'MY-XEN-USER',
  xenserver_password: 'MY-XEN-PASSWORD',
  xenserver_defaults: {
    'template' => 'ubuntu-14.04'
  }
}
```

For a full example see [examples/xenserver/simple.rb](examples/xenserver/simple.rb).

### Scaleway

You should configure the driver with your credentials or :

``` ruby
with_driver "fog:Scaleway:Your-Organisation-UUID:region", compute_options: {
  scalewat_token: 'your-api-token',
}
```

or just use the fog configuration (~/.fog):

``` ruby
with_driver 'fog:Scaleway'
```

For full examples, see [examples/scaleway](examples/scaleway).

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

The machine resources from the [cluster.rb example](https://github.com/chef/chef-provisioning/blob/master/docs/examples/cluster.rb) are pretty straightforward.  Here's a copy/paste, it'll create a database machine then one web server.

```ruby
machine 'mario' do
  recipe 'postgresql'
  recipe 'mydb'
  tag 'mydb_master'
end

num_webservers = 1

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
[joyent_howto]: https://numericillustration.wordpress.com/2015/12/04/using-chef-provisioner-with-the-joyent-smart-data-center/
[freenode_smartos]: http://webchat.freenode.net/?randomnick=1&channels=smartos&prompt=1
