source "https://rubygems.org"

gemspec

group :development do
  gem "chef"
  gem "chefstyle", "~> 0.10.0"
  # fog-google and fog-aws have been removed as direct deps, but are necessary for testing
  gem "fog-aws"
  gem "fog-google"
  # fog is necessary for fog-cloudstack
  gem "fog"
  gem "guard"
  gem "guard-rspec"
  gem "rake"
  gem "rspec", "~> 3.0"
  gem "simplecov"
  gem "winrm-elevated"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
  gem "rb-readline"
end

group :docs do
  gem "github-markup"
  gem "redcarpet"
  gem "yard"
end

instance_eval(ENV["GEMFILE_MOD"]) if ENV["GEMFILE_MOD"]

# If you want to load debugging tools into the bundle exec sandbox,
# add these additional dependencies into Gemfile.local
eval_gemfile(__FILE__ + ".local") if File.exist?(__FILE__ + ".local")
