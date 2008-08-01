require 'rubygems'
require 'soap/rpc/driver'
require 'xmlsimple'


module Mobile
  
  # Required values when using this service
  # :username => String
  # :pin => String
  # :server => String
  class GlobeProxy < Base
    include Validation
    
    # This is the version of the API that we will use
    API_VERSION = '1.03'
  
    def initialize(params = {})
      params = {
        :transport => 'soap',
        :namespace => 'http://ESCPlatform/xsd'
      }.merge(params)

      super(params)
      validate_presence_of :username, :pin, :server, :transport, :in => @params            
    end
    
    def server
      @server ||= send("initialize_proxy_#{@params[:transport]}", @params)
    end
    
    def send_sms(sms)
      validate_presence_of :to, :message, :in => sms
      server.send_sms(
        @params[:username], 
        @params[:pin],
        sms[:to], 
        sms[:message],
        sms[:display] || '1',
        sms[:user_data_header] || '',
	      sms[:message_waiting_indicator] || '',
        sms[:coding] || '0'
      )
    end

    def send_mms(mms)
      validate_presence_of :to, :subject, :in => mms
      server.send_mms(
        @params[:username],
        @params[:pin],
        mms[:to],
        mms[:subject],
        mms[:body] || ''
      )
    end
    
    class << self
      def parse_callback_xml(xml)
        GlobeCallback.parse_xml(xml)
      end
    end
    
    #######
    private
    #######
    
    def initialize_proxy_soap(params)
      ProxySoap.new(params)      
    end
    
    class ProxySoap
      def initialize(params)
        @server = SOAP::RPC::Driver.new(params[:server], params[:namespace])
        @server.add_method('sendSMS', 'uName', 'uPin', 'MSISDN', 'messageString',
          'Display', 'udh', 'mwi', 'coding')

        @server.add_method('sendMMS', 'uName', 'uPin', 'MSISDN', 'Subject', 'SMIL')
      end
      
      def send_sms(uname, upin, msisdn, message, display, udh, mwi, coding)
        result = @server.sendSMS(uname, upin, msisdn, message, display, udh, mwi, coding)
        GlobeProxyResponse.new(result.to_i)
      end

      def send_mms(u_name, u_pin, msisdn, subject, smil)
        result = @server.sendMMS(u_name, u_pin, msisdn, subject, smil)

        # XXX API bug? If smil is not well-formed, sendMMS returns an empty
        # SOAP::Mapping::Object. For now, force the result to "402 MMS sending failed"
        result = 402 if result.is_a? SOAP::Mapping::Object
        GlobeProxyResponse.new(result.to_i)
      end
    end
    
    class GlobeCallback
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
  end
  
  class GlobeProxyResponse
    attr_reader :code
    
    @@error_map = {
      :sms_accepted? => 201,
      :sms_failed?   => 401,
      :mms_accepted? => 202,
      :mms_failed?   => 402,
      :not_allowed?  => 301,
      :cap_exceeded? => 302,
      :invalid_size? => 303,
      :connection_exceeded? => 304,
      :invalid_login?   => 305,
      :invalid_target?  => 501,
      :invalid_display? => 502,
      :invalid_mwi?     => 503,
      :invalid_coding?  => 504,
    }
    
    def initialize(code)
      @code = code
    end
    
    def valid?
      [201, 202].include?(@code)
    end

    def method_missing(method_id)
      if code = @@error_map[method_id.to_sym]
        @code == code
      else
        raise NoMethodError, "undefined GlobeProxyResponse matcher"
      end
    end
  end
  

end
