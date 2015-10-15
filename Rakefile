require "bundler/gem_tasks"
require "standalone_migrations"
require 'rspec/core/rake_task'

StandaloneMigrations::Tasks.load_tasks

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
  t.rspec_opts = '--format documentation'
end

task :travis do
  Rake::Task['db:setup'].invoke
  Rake::Task[:spec].invoke
end

