require File.dirname(__FILE__) + '/test_helper.rb'

describe "using Globe Mobile API" do  
  def valid_proxy_params
    {
      :username => ENV['GT_USERNAME'] || 'moko',
      :pin      => ENV['GT_PIN']  || '1234',
    }
  end
  
  def valid_sms_params
    {
      :to => valid_globe_users[:greg][:phone],
      :message  => 'hello. using globe sms api'
    }
  end

  def valid_mms_params
    {
      :to => valid_globe_users[:greg][:phone],
      :subject => 'Testing using MMS api',
      :body => '<smil></smil>'
    }
  end

  describe "required parameters on initialization" do
    before(:each) do
      @params = valid_proxy_params
    end
  
    [:username, :pin].each do |param|
      it "should require #{param}" do
        @params.delete(param)
        lambda {
          Mobile::GlobeProxy.new(@params)
        }.should raise_error(ArgumentError)
      end
      
      it "should not be empty #{param}" do
        @params.merge!(param => '')
        lambda {
          Mobile::GlobeProxy.new(@params)
        }.should raise_error(ArgumentError)
      end
    end
  end

  def server
    @server ||= Mobile::GlobeProxy.new(valid_proxy_params)
  end
    
  describe "to send an SMS" do
    before do
      @params = valid_sms_params
    end

    it 'should succeed' do
      server.send_sms(@params).should be_sms_accepted
    end

    [:to, :message].each do |param|
      it "should require #{param} parameter" do
        @params.delete(param)
        lambda do
          server.send_sms(@params)
        end.should raise_error(ArgumentError)
      end
    end
  end
  
  describe "SMS callback data" do
    def valid_sms_xml
      %{
      <?xml version="1.0" encoding="utf-8"?>
      <message>
      <param>
        <name>id</name>
        <value>unique-id</value>
      </param>
      <param>
        <name>source</name>
        <value>source-123</value>
      </param>
      <param>
        <name>target</name>
        <value>target-123</value>
      </param>
      <param>
        <name>msg</name>
        <value>message</value>
      </param>
      <param>
        <name>unknown</name>
        <value>unknown</value>
      </param>      
      </message>
      }
    end
    
    def sms_data
      @sms ||= Mobile::GlobeProxy.parse_callback_xml(valid_sms_xml)
    end
    
    [:id, :sender, :recipient, :message].each do |param|
      it "should have #{param}" do
        sms_data[param].should_not be_empty
      end
    end
    
    it "should capture unknown params" do
      sms_data[:unknown].should_not be_empty
    end
  end

  describe 'to send an MMS' do
    before do
      @params = valid_mms_params
    end

    it 'should succeed' do
      server.send_mms(@params).should be_mms_accepted
    end

    [:to, :subject].each do |param|
      it "should require #{param} parameter" do
        @params.delete(param)
        lambda do
          server.send_mms @params
        end.should raise_error(ArgumentError)
      end
    end

    it 'should fail gracefully if smil is not well-formed' do
      @params[:body] = 'not well-formed smil'
      server.send_mms(@params).should be_mms_failed
    end
  end

  describe "MMS callback data" do
    def valid_mms_xml
      %{
      <?xml version="1.0" encoding="utf-8"?>
      <message>
      <param>
        <name>messageType</name>
        <value>MMS</value>
      </param>
      <param>
        <name>subject</name>
        <value>subject</value>
      </param>
      <param>
        <name>source</name>
        <value>source-123</value>
      </param>
      <param>
        <name>target</name>
        <value>target-123</value>
      </param>
      <param>
        <name>file</name>
        <value>
          <file>http://localhost:1234/testing.jpg</file>
          <file>http://localhost:1234/testing.txt</file>
        </value>
      </param>
      <param>
        <name>unknown</name>
        <value>unknown</value>
      </param> 
      </message>
      }
    end
  
    def mms_data
      @mms ||= Mobile::GlobeProxy.parse_callback_xml(valid_mms_xml)
    end
    
    [:type, :subject, :files, :sender, :recipient].each do |param|
      it "should have #{param}" do
        mms_data[param].should_not be_empty
      end
    end
    
    it "should capture unknown params" do
      mms_data[:unknown].should_not be_empty
    end
  end
  
  describe "Proxy response" do
    before do
      @params = valid_sms_params
    end

    it do
      server.send_sms(@params)
      server.response.response_code.should_not be_nil
      server.response.message.should_not be_empty
    end
  end
end

