module Mobile::Globe:Callback
  @@field_map = {
    'id'          => :id,        # unique message identifier
    'source'      => :sender,    # sender MSISDN/cellular number
    'target'      => :recipient, # receiver MSISDN/cellular number
    'msg'         => :message,   # message
    'file'        => :files,     # MMS attachments
    'subject'     => :subject,   # MMS subject
    'messageType' => :type,      # "SMS" or "MMS"
    'type'        => :status     # delivery status report code
  }
  
  class << self
    def parse_xml(xml)
      # TODO: replace with hpricot
      message = XmlSimple.xml_in(xml)
      message['param'].inject({}) do |h, param|
        k, v = param['name'].first, param['value'].first
        # Should still capture unknown parameters
        h[(f = @@field_map[k]) ? f : k.to_sym] = v
        h
      end
    end
  end
end
