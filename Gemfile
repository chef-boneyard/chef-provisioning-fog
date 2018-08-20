source "https://rubygems.org"

gemspec

group :development do
  # fog-google and fog-aws have been removed as direct deps, but are necessary for testing
  gem "fog-google"
  gem "fog-aws"
  # fog is necessary for fog-cloudstack
  gem "fog"
  gem "chef"
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-readline'
  gem 'simplecov'
  gem 'winrm-elevated'
  gem "rspec", "~> 3.0"
  gem 'rake'
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
end

instance_eval(ENV["GEMFILE_MOD"]) if ENV["GEMFILE_MOD"]

# If you want to load debugging tools into the bundle exec sandbox,
# add these additional dependencies into Gemfile.local
eval_gemfile(__FILE__ + ".local") if File.exist?(__FILE__ + ".local")
