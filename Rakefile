require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Run tests'
RSpec::Core::RakeTask.new(:spec)

desc 'Run Rubocop on the gem'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb', 'spec/**/*.rb']
  task.fail_on_error = true
end

desc 'Install SASS tools'
task :install do
  Dir.chdir('public/sass') do
    %w(bourbon neat bitters).each { |x| system x, 'install' }
  end
end

task default: [:spec, :rubocop]
