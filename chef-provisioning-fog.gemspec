$:.unshift(File.dirname(__FILE__) + '/lib')
require 'chef/provisioning/fog_driver/version'

Gem::Specification.new do |s|
  s.name = 'chef-provisioning-fog'
  s.version = Chef::Provisioning::FogDriver::VERSION
  s.platform = Gem::Platform::RUBY
  s.extra_rdoc_files = ['README.md', 'LICENSE' ]
  s.summary = 'Driver for creating Fog instances in Chef Provisioning.'
  s.description = s.summary
  s.authors     = ['John Keiser', "Chris McClimans", "Taylor Carpenter", "Wavell Watson"]
  s.email = ['jkeiser@getchef.com', 'hh@vulk.co', 't@vulk.co', 'w@vulk.co']
  s.homepage = 'https://github.com/opscode/chef-provisioning-fog'

  s.add_dependency 'chef-provisioning', '~> 1.0'
  s.add_dependency 'fog'
  s.add_dependency 'retryable'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'

  s.bindir       = "bin"
  s.executables  = %w( )

  s.require_path = 'lib'
  s.files = %w(Gemfile Rakefile LICENSE README.md) + Dir.glob("*.gemspec") +
      Dir.glob("{distro,lib,tasks,spec}/**/*", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
end
