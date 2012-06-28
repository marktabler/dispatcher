#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'resque/tasks'

desc 'Default: run specs.'
task :default => :spec

task "resque:setup" do
  require "ferrety/dispatcher"
end

RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end