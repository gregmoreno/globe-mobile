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
    
    def send_sms(msg)
      server.send_sms(
        @params[:username], 
        @params[:pin],
        msg[:receiver], 
        msg[:message],
        '0',
        '', '',
        '0'
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
      end
      
      def send_sms(uname, upin, msisdn, message, display, udh, mwi, coding)
        result = @server.sendSMS(uname, upin, msisdn, message, display, udh, mwi, coding)
        GlobeProxyResponse.new(result.to_i)
      end
    end
    
    class GlobeCallback
      @@field_map = {
        'id'     => :id,
        'source' => :sender,
        'target' => :receiver,
        'msg'    => :message,
        'file'   => :file,
        'subject'     => :subject,
        'messageType' => :type
      }
      
      class << self
        def parse_xml(xml)
          message = XmlSimple.xml_in(xml)
          message['param'].inject({}) do |h, param|
            k, v = param['name'].first, param['value'].first
            h[@@field_map[k]] = v
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