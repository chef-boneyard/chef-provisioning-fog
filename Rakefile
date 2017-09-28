require 'bundler'
require 'bundler/gem_tasks'

desc "run specs"
task :spec do
  sh "bundle exec rspec"
end

begin
  require "github_changelog_generator/task"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.future_release = Chef::Provisioning::FogDriver::VERSION
    config.enhancement_labels = "enhancement,Enhancement,New Feature".split(",")
    config.bug_labels = "bug,Bug,Improvement,Upstream Bug".split(",")
    config.exclude_labels = "duplicate,question,invalid,wontfix,no_changelog,Exclude From Changelog,Question".split(",")
  end
rescue LoadError
end
