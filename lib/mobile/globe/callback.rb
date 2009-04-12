module Mobile::Globe

  class Callback
    include ClassUtilMixin

    @@DEFAULT_ATTRIBUTES = [:id, :source, :target, :msg, :files, :subject, :type, :status]
    attr_accessor *@@DEFAULT_ATTRIBUTES

    set_attribute_aliases :message => :msg,
                          :to_number => :target,
                          :from_number => :source
  
    class << self
      def parse_xml(xml)
        # Because of some ambiguity in the API
        field_map = {
          'file'        => :files,
          'messageType' => :type,   # "SMS" or "MMS"
          'type'        => :status  # delivery status report code
        }

        message = XmlSimple.xml_in(xml)
        data = message['param'].inject({}) do |h, param|
          k, v = param['name'].first, param['value'].first
          h[(f = field_map[k]) ? f : k.to_sym] = v
          h
        end

        attr_accessor *(data.keys - @@DEFAULT_ATTRIBUTES)
        self.new(data)
      end
    end

  end

end
