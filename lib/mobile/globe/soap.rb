require 'soap/rpc/driver'

module Mobile::Globe::SOAP
  @@defaults = {
    :namespace => 'http://ESCPlatform/xsd',
    :url       => 'http://iplaypen.globelabs.com.ph:1881/axis2/services/Platform/'
  }

  class Client
    include ClassUtilMixin  
    @@ATTRIBUTES = [
      :username,
      :pin,
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

    [:username, :pin].each do |required|
      raise "#{required} must be configured" unless @@config.send(required)  
    end
    @@config
  end # configure

  class Client
    def send_sms(sms={})
      result = proxy.sendSMS(
        self.username, 
        self.pin,
        sms[:to], 
        sms[:message],
        sms[:display] || '1',
        sms[:user_data_header] || '',
	      sms[:message_waiting_indicator] || '',
        sms[:coding] || '0'
      )
      Mobile::Globe::Response.new(result)
    end

    def send_mms(mms={})
      result = proxy.sendMMS(
        self.username,
        self.pin,
        mms[:to],
        mms[:subject],
        mms[:body] || ''
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
