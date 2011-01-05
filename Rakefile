require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "acts_as_ordinalized"
    gem.summary = %Q{simple gem providing active record collections with ordinal numbers}
    gem.description = %Q{This is a simple acts_as gem providing the active record models with ordinal numbers. The ordinals numbering is per query, but should work nicely with will paginate showing correct ordinal numbers on paginated results.}
    gem.email = "mandaryyyn@gmail.com"
    gem.homepage = "http://github.com/mandaryn/acts_as_ordinalized"
    gem.authors = ["mandaryn"]
    gem.add_dependency "will_paginate"
    gem.add_dependency "rails", ">= 2.3.5"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "acts_as_ordinalized #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
