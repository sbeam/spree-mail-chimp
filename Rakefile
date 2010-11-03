require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the mail_chimp extension.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  desc 'Functional test the mail_chimp extension.'
  Rake::TestTask.new(:functionals) do |t|
    t.libs << 'lib'
    t.pattern = 'test/functional/*_test.rb'
    t.verbose = true
  end

  desc 'Unit test the mail_chimp extension.'
  Rake::TestTask.new(:units) do |t|
    t.libs << 'lib'
    t.pattern = 'test/unit/*_test.rb'
    t.verbose = true
  end
end

desc 'Generate documentation for the mail_chimp extension.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'MailChimpExtension'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.markdown')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# Load any custom rakefiles for extension
Dir[File.dirname(__FILE__) + '/lib/tasks/*.rake'].sort.each { |f| require f }
