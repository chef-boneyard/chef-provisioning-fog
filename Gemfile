source "https://rubygems.org"
gemfile
gemspec

group :development do
  gem "chef", git: "https://github.com/chef/chef" if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("2.2.2") # until stable 12.14 is released (won't load new cheffish and such otherwise)
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-readline'
  gem 'simplecov'
  gem 'winrm-elevated'
end
