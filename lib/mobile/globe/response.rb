module Mobile::Globe
  class Response
    attr_reader :response_code
    
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
      :argument_too_large? => 507,
      :malformed_smil?  => 509,
    }
    
    @@status_messages = {
      201 => "SMS Accepted for delivery",
      202 => "MMS Accepted for delivery",
      301 => "User is not allowed to access this service",
      302 => "User exceeded daily cap",
      303 => "Invalid message_length",
      304 => "Maximum number of simultaneous connections reached",
      305 => "Invalid login credentials",
      401 => "SMS sending failed",
      402 => "MMS sending failed",
      501 => "Invalid target MSISDN",
      502 => "Invalid display type",
      503 => "Invalid MWI",
      504 => "Invalid coding",
      505 => "Empty value given in required argument",
      506 => "Badly formed XML in SOAP request",
      507 => "Argument too large",
      509 => "Malformed SMIL"
    }
    
    def initialize(code)
      @response_code = code.to_i
    end
    
    def valid?
      [201, 202].include?(self.response_code)
    end

    def to_s 
      "#{self.response_code} - #{message}"
    end
    
    def message(code = self.response_code)
      if msg = @@status_messages[code]
        msg
      else
        raise ArgumentError, "undefined response code"
      end
    end

    def method_missing(method_id)
      if code = @@error_map[method_id.to_sym]
        self.response_code == code
      else
        raise NoMethodError
      end
    end
  end
end
