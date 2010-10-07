# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'



spec = Gem::Specification.new do |s|
  s.name = 'slideshare4r'
  s.version = '0.0.1'
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
  s.requirements << 'nokogiri v1.4.3.1 or greater'
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
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts=["-f s"]
  t.spec_files = FileList['spec/**/*.rb']
end

task :default => [:spec,:test]
