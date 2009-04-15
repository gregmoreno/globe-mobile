require File.dirname(__FILE__) + '/test_helper.rb'

describe "Globe Mobile API" do  
  
  def valid_sms_params
    {
      :to_number => from_config[:to_number],
      :message  => 'hello. using globe sms api'
    }
  end

  def valid_mms_params
    {
      :to_number => from_config[:to_number], 
      :subject => 'Testing using MMS api',
      :body => '<smil></smil>'
    }
  end

  def client
    @client ||= initialize_client 
  end

  describe "valid sms", :shared => true do
    it "should send" do
      client.send_sms(valid_sms_params).should be_sms_accepted
    end
  end

  describe "valid mms", :shared => true do
    it "send mms" do
      client.send_mms(valid_mms_params).should be_mms_accepted
    end 
  end

  describe "using SOAP" do
    def initialize_client
      Mobile::Globe::SOAP::Client.configure do |config|
        config.user_name = from_config[:user_name]
        config.user_pin  = from_config[:user_pin]
      end
    end

    it_should_behave_like "valid sms"
    it_should_behave_like "valid mms"
  end

  describe "using REST" do
    def initialize_client
      Mobile::Globe::REST::Client.configure do |config|
        config.user_name = from_config[:user_name]
        config.user_pin  = from_config[:user_pin]
      end
    end

    it_should_behave_like "valid sms"
    it_should_behave_like "valid mms"
  end


  describe "sms" do
    before(:each) do
      @sms = Mobile::Globe::SMS.new
    end

    {:to_number => :MSISDN,
     :message   => :messageString,
     :display   => :Display
    }.each do |k, v|
      class_eval <<-RUBY
        it "should alias #{k} and #{v}" do
          @sms.#{v} = 'alpha'
          @sms.#{k}.should == 'alpha'

          @sms.#{k} = 'bravo'
          @sms.#{v}.should == 'bravo'
        end
      RUBY
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
        <name>messageType</name>
        <value>SMS</value>
      </param>
      <param>
        <name>type</name>
        <value>Status</value>
      </param>
      <param>
        <name>unknown</name>
        <value>unknown</value>
      </param>      
      </message>
      }
    end
    
    def data
      @sms ||= Mobile::Globe::Callback.parse_xml(valid_sms_xml)
    end
    
    it "should retrieve param" do
      [:id, :source, :target, :msg, :unknown].each do |param|
        data.send("#{param}").should_not be_empty
      end
    end

    it "should work with aliases and param name change" do
      [:type, :status].each do |param|
        data.send("#{param}").should_not be_empty
      end
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
  
    def data
      @mms ||= Mobile::Globe::Callback.parse_xml(valid_mms_xml)
    end
    
    it "should have param" do
      [:source, :target, :unknown].each do |param|
        data.send("#{param}").should_not be_empty
      end
    end

    it "should work with aliases and param name change" do
      [:type, :files].each do |param|
        data.send("#{param}").should_not be_empty
      end
    end
    
  end
  
end

