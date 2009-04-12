module Mobile::Globe::REST

  class Client
    include ClassUtilMixin  
    include Mobile::Globe::Configuration 

    set_default_attributes :user_name => nil,
                           :user_pin  => nil,
                           :url       => 'http://iplaypen.globelabs.com.ph:1881/axis2/services/Platform'

    def send_sms(data)
      sms = data.is_a?(Mobile::Globe::SMS) ? data.attributes : Mobile::Globe::SMS.new(data).attributes
      sms.merge!(:uName => self.user_name, :uPin => self.user_pin) 
      create_http_post_request('sendSMS', sms)
    end

    def send_mms(data)
      mms = data.is_a?(Mobile::Globe::MMS) ? data.attributes : Mobile::Globe::MMS.new(data).attributes
      mms.merge!(:uName => self.user_name, :uPin => self.user_pin)
      create_http_post_request('sendMMS', mms)
    end

    protected

    def create_http_post_request(action, params = {})
      url = URI.parse("#{self.url}/#{action}") 
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data(params)
      response = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
      case response
      when Net::HTTPSuccess, Net::HTTPRedirection
        xml =  XmlSimple.xml_in(response.body || '') 
        return Mobile::Globe::Response.new(xml['return'].first)
      else
        res.error!
      end
    end

  end
end
