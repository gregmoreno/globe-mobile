module Mobile
  module SOAP
    class Config
      include ClassUtilMixin
      @@ATTRIBUTES = [
        :url,
        :namespace
      ]
      attr_accessor *@@ATTRIBUTES
    end
  end
end
