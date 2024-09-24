# frozen_string_literal: true

require 'rubocop/rake_task'

task default: %w[lint test]

RuboCop::RakeTask.new(:lint) do |task|
  task.patterns = ['lib/**/*.rb', 'test/**/*.rb', 'Rakefile']
  task.fail_on_error = false
end

RuboCop::RakeTask.new(:fix) do |task|
  task.patterns = ['lib/**/*.rb', 'test/**/*.rb']
  task.fail_on_error = false
  task.options << '--autocorrect'
end

task :run do
  # ruby lib/
end

task :test do
  ruby 'test/test_music_app.rb'
end
