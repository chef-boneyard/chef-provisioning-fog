$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
$LOAD_PATH.unshift File.expand_path("support", __dir__)
require "fog"
require "chef/provisioning"
require "chef/provisioning/fog_driver/driver"
require "simplecov"

SimpleCov.start do
  # add_filter do |source_file|
  #   # source_file.lines.count < 5
  #   source.filename =~ /^#{SimpleCov.root}\/chef-provisioning-fake/)
  # end
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end

Fog.mock!
