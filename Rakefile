require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

begin
  require "yard"
  YARD::Rake::YardocTask.new(:docs)
rescue LoadError
  puts "yard is not available. bundle install first to make sure all dependencies are installed."
end

task :console do
  require "irb"
  require "irb/completion"
  ARGV.clear
  IRB.start
end

task :default => :spec
