require 'rake'
require 'rspec/core/rake_task'

task :spec    => 'spec:all'
task :default => :spec

namespace :spec do
  targets = []
  Dir.glob('./spec/*').each do |dir|
    next unless File.directory?(dir)
    target = File.basename(dir)
    target = "_#{target}" if target == "default"
    targets << target
  end

  # Use multitask for parallel execution
  multitask :all     => targets
  task :default => :all

  targets.each do |target|
    original_target = target == "_default" ? target[1..-1] : target
    desc "Run serverspec tests to #{original_target}"
    task target.to_sym do
      # Run RSpec in a separate process with environment variable set
      # This ensures each parallel task has its own isolated environment
      sh "TARGET_HOST=#{original_target} bundle exec rspec spec/#{original_target}/*_spec.rb"
    end
  end
end
