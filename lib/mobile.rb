require 'rubygems'

module Mobile; end

require 'nokogiri'
require 'net/https'
require 'uri'

def require_local(suffix)
  require(File.expand_path(File.join(File.dirname(__FILE__), suffix)))
end

require_local('mobile/support')
require_local('mobile/version')
require_local('mobile/globe')

