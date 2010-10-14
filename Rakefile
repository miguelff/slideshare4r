# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rspec/core/rake_task'



spec = Gem::Specification.new do |s|
  s.name = 'slideshare4r'
  s.version = '0.4.0'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'Slideshare API ruby wrapper'
  s.description = s.summary
  s.author = 'Miguel Fernandez Fernandez (miguelff at github.org)'
  s.email = 'miguelfernandezfernandez@gmail.com'
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
  s.add_dependency('nokogiri', '>= 1.4.3.1')
  s.add_dependency('rest-open-uri', '>= 1.0.0')
  s.add_dependency('mime-types', '>= 1.16')
  s.requirements << 'nokogiri v1.4.3.1 or greater'
  s.requirements << 'rest-open-uri v1.0.0 or greater'
  s.requirements << 'mime-types v1.16 or greater'

end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "slideshare4r Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

desc "Run all tasks"
Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts=["-f s"]
  t.pattern = 'spec/**/*.rb'
end

task :default => [:spec,:test]
