$:.unshift(File.dirname(__FILE__) + '/lib')
require 'chef/provisioning/fog_driver/version'

Gem::Specification.new do |s|
  s.name = 'chef-provisioning-fog'
  s.version = Chef::Provisioning::FogDriver::VERSION
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE' ]
  s.summary = 'Driver for creating Fog instances in Chef Provisioning.'
  s.description = s.summary
  s.authors     = ['John Keiser', "Chris McClimans", "Taylor Carpenter", "Wavell Watson", "JJ Asghar"]
  s.email = ['john@johnkeiser.com', 'hh@vulk.co', 't@vulk.co', 'w@vulk.co','jj@chef.io']
  s.homepage = 'https://github.com/chef/chef-provisioning-fog'

  s.add_dependency 'chef-provisioning', '>= 1.0', '< 3.0'
  s.add_dependency 'cheffish', '>= 13.1.0', '< 14.0'
  #
  # NOTE: the `fog` direct dependency has been removed from chef-provisioning-fog, if there is no meta-gem
  # then users _must_ install the fog dependency manually (`chef gem install fog` for chefdk).  this affects
  # at least cloudstack and vcair users.  aws users should use chef-provisioning-aws.
  #
  # s.add_dependency 'fog-aws'     # Deliberately removed: chef-provisioning-aws is preferred
  s.add_dependency 'fog-digitalocean'
  # s.add_dependency 'fog-google'  # Deliberately removed: fog-google is broken with newer google-api-client
  s.add_dependency 'fog-joyent'
  s.add_dependency 'fog-openstack'
  s.add_dependency 'fog-rackspace'
  s.add_dependency 'fog-scaleway'
  s.add_dependency 'fog-softlayer'
  s.add_dependency 'fog-xenserver'
  s.add_dependency 'retryable'
  s.add_dependency 'winrm-elevated'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'

  s.bindir       = "bin"
  s.executables  = %w( )

  s.require_path = 'lib'
  s.files = %w(Gemfile Rakefile LICENSE README.md) + Dir.glob("*.gemspec") +
      Dir.glob("{distro,lib,tasks,spec}/**/*", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
end
