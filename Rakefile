require 'rake'
require 'spec/rake/spectask'

desc "Run all tests"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['test/*.rb'] - ['test/test_helper.rb']
  t.verbose = true
end
