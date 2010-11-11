require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "monster_mash"
    gem.summary = %Q{Provides a fun HTTP interface on top of Typhoeus!}
    gem.description = %Q{Provides a fun HTTP interface on top of Typhoeus!}
    gem.email = "dbalatero@gmail.com"
    gem.homepage = "http://github.com/dbalatero/monster_mash"
    gem.authors = ["David Balatero"]
    gem.add_dependency "typhoeus", ">= 0.1.25"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "typhoeus_spec_cache", ">= 0.2.2"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "monster_mash #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
