module ClassUtilMixin
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend ClassMethods
  end

  module ClassMethods
    def set_default_attributes(data)
      attr_accessor *data.keys
      define_method(:default_attributes){ data  }
    end

    def set_attribute_aliases(attribs)
      attribs.each do |k, v|
        class_eval <<-RUBY
          alias_method :#{k},  :#{v} 
          alias_method :#{k}=, :#{v}=
        RUBY
      end
    end

  end # ClassMethods

  module InstanceMethods
    def initialize(params = {})
      init = self.respond_to?(:default_attributes) ? self.default_attributes.merge(params) : params 
      init.each do |k,v|
        self.send("#{k}=", v) if self.respond_to?(k)
      end
    end

    def attributes
      h = {}
      self.default_attributes.keys.each do |k|
        h[k] = self.send(k) if self.respond_to?(k)
      end
      h
    end

  end # InstanceMethods

end # ClassUtilMixin

