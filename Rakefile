require "bundler/gem_tasks"
task :default => :spec

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
  t.stats_options = ['--list-undoc']
end
