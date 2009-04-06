require 'soap/rpc/driver'

module Mobile::Globe::SOAP
  @@defaults = {
    :namespace => 'http://ESCPlatform/xsd',
    :url       => 'http://iplaypen.globelabs.com.ph:1881/axis2/services/Platform/'
  }

  class Client
    include ClassUtilMixin  
    @@ATTRIBUTES = [
      :user_name,
      :user_pin,
      :url,
      :namespace
    ]
    attr_accessor *@@ATTRIBUTES
  end
  @@config = Client.new(@@defaults)

  # TODO: configuration is shared among SOAP and REST
  def self.configure(&block)
    raise ArgumentError, "Block must be provided to configure" unless block_given?
    yield @@config

    [:user_name, :user_pin].each do |required|
      raise "#{required} must be configured" unless @@config.send(required)  
    end
    @@config
  end # configure

  class Client
    def send_sms(data)
      sms = data.is_a?(Mobile::Globe::SMS) ? data : Mobile::Globe::SMS.new(data)
      result = proxy.sendSMS(
        self.user_name, 
        self.user_pin,
        sms.to_number,
        sms.message,
        sms.display,
        sms.udh,
        sms.mwi,
        sms.coding
      )
      Mobile::Globe::Response.new(result)
    end

    def send_mms(data)
      mms = data.is_a?(Mobile::Globe::MMS) ? data : Mobile::Globe::MMS.new(data)
      result = proxy.sendMMS(
        self.user_name,
        self.user_pin,
        mms.to_number,
        mms.subject,
        mms.body
      )
      Mobile::Globe::Response.new(result)
    end

    protected

    def proxy
      @proxy ||= create_proxy
    end

    def create_proxy
      server = SOAP::RPC::Driver.new(self.url, self.namespace)
      server.add_method('sendSMS', 'uName', 'uPin', 'MSISDN', 'messageString',
            'Display', 'udh', 'mwi', 'coding')
      server.add_method('sendMMS', 'uName', 'uPin', 'MSISDN', 'Subject', 'SMIL')
      server 
    end
  end

end
