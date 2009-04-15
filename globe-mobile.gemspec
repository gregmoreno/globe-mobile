require 'rubygems'
Gem::Specification.new do |s|
  s.name     = "globe-mobile"
  s.version  = "0.0.3"
  s.author   = "Greg Moreno"
  s.email    = "greg.moreno@gmail.com"
  s.homepage = "http://www.globelabs.com.ph"
  s.summary  = "A wrapper for sending SMS/MSS using Globe Telecoms API."
  s.description = s.summary
  s.files = Dir.glob("{lib,test}/**/*")
  
  s.require_path = "lib"

  s.add_dependency "soap4r"
  s.add_dependency "nokogiri"
end
