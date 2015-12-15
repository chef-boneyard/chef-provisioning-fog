require 'bundler'
require 'bundler/gem_tasks'
require 'bump'
require 'github_changelog_generator'

task :spec do
  require File.expand_path('spec/run')
end

desc 'Sanity Checks and releases gem to rubygems'
task :sanity do
  # Bumps the version.rb patch version (there are gems that can handle this for us)
  Rake::Task[:minor].invoke

  # Runs github_changelog_generator to update the CHANGELOG.rb per the release guide
  # need to figure out how to check for https://github.com/skywinder/github-changelog-generator#github-token
  sh 'github_changelog_generator'

  # Commits those as a change to master (git commit -am "Preparing the #{future_version} release" && git push)
  future_version = Bump::Bump.current
  sh "git commit -am 'Preparing for #{future_version} release' && git push"

  # Runs git tag to take the release (git tag -a "Releasing #{future_version}" && git push --tags)
  sh "git tag -a 'Releasing #{future_version}' && git push --tags"

  # need to add rake release here :)
end

desc 'Does a patch bump to the gem'
task :patch do
  Bump::Bump.run("patch")
end

desc 'Does a minor bump to the gem'
task :minor do
  Bump::Bump.run("minor")
end
