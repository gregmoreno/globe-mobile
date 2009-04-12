module ClassUtilMixin
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend ClassMethods
  end

  module ClassMethods
    def set_default_attributes(data)
      attr_accessor *data.keys
      define_method(:default_attributes) { data  }
    end

    def set_attribute_aliases(attribs)
      attribs.each do |k, v|
        class_eval <<-EOF
          alias_method :#{k},  :#{v} 
          alias_method :#{k}=, :#{v}=
        EOF
      end
      define_method(:attribute_aliases) { attribs }
    end

  end # ClassMethods

  module InstanceMethods
    def initialize(params = {})
      init = if self.respond_to?(:default_attributes) and self.respond_to?(:attribute_aliases)
        used_aliases = params.keys.inject([]) do |l, k|
          l << self.attribute_aliases[k] if self.attribute_aliases.keys.include?(k)
          l
        end
        default = self.default_attributes
        default.delete_if { |k, v| used_aliases.include?(k) }
        default.merge(params)
      elsif self.respond_to?(:default_attributes)
        self.default_attributes.merge(params)
      else
        params
      end

      #p init
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

