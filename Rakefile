# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "raq"
  gem.homepage = "http://github.com/cpb/raq"
  gem.license = "MIT"
  gem.summary = %Q{Middleware for your AMQP Message Consumer}
  gem.description = %Q{The elegance of Rack with none of the unreliability of HTTP}
  gem.email = "me@cpb.ca"
  gem.authors = ["Caleb Buxton"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)
Cucumber::Rake::Task.new(:aruba_features) do |t|
  t.cucumber_opts = "ARUBA_REPORT_DIR=doc --format progress"
end

task :aruba_doc => [:check_aruba_doc_dependencies, :aruba_features]

task :check_aruba_doc_dependencies do
  unless system('pygmentize',[:err,:out]=>"/dev/null")
    puts "Generating Aruba Reports depends on Pygments."
    puts "Check http://pygments.org/"
    puts "Or you can just try `easy_install Pygments`"
    puts
    raise "You do not have all the dependencies required to generate Aruba Reports"
  end
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "raq #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :doc => [:rdoc,:aruba_doc]
