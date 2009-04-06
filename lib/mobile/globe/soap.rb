require 'soap/rpc/driver'

module Mobile::Globe::SOAP

  class Client
    include ClassUtilMixin  
    include Mobile::Globe::Configuration

    set_default_attributes :user_name => nil,
                           :user_pin  => nil,
                           :namespace => 'http://ESCPlatform/xsd',
                           :url       => 'http://iplaypen.globelabs.com.ph:1881/axis2/services/Platform/'

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
