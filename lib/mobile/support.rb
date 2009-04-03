# Cherry-picked from twitter4r/lib/twitter/ext/stdlib.rb

# Extension to Hash to create URL encoded string from key-values
class Hash
  # Returns string formatted for HTTP URL encoded name-value pairs.
  # For example,
  # {:id => 'thomas_hardy'}.to_http_str
  # # => "id=thomas_hardy"
  # {:id => 23423, :since => Time.now}.to_http_str
  # # => "since=Thu,%2021%20Jun%202007%2012:10:05%20-0500&id=23423"
  def to_http_str
    result = ''
    return result if self.empty?
    self.each do |key, val|
      result << "#{key}=#{CGI.escape(val.to_s)}&"
    end
    result.chop # remove the last '&' character, since it can be discarded
  end
end


module ClassUtilMixin #:nodoc:
  def self.included(base) #:nodoc:
    base.send(:include, InstanceMethods)
  end
  
  module InstanceMethods #:nodoc:
    def initialize(params = {})
      params.each do |key,val|
        self.send("#{key}=", val) if self.respond_to? key
      end
      self.send(:init) if self.respond_to? :init
    end
    
    protected
      # Helper method to provide an easy and terse way to require
      # a block is provided to a method.
      def require_block(block_given)
        raise ArgumentError, "Must provide a block" unless block_given
      end
  end
end # ClassUtilMixin

