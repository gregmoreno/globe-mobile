require 'mobile'

client = Mobile::Globe::SOAP.configure do |config|
#client = Mobile::Globe::REST.configure do |config|
  config.user_name = 'greg'
  config.user_pin = '1234'
end

#puts client.send_sms(:to_number => '1234')
sms = Mobile::Globe::SMS.new({:to_number => '5678'})
p sms.to_h
#puts client.send_sms(sms)

#puts client.send_mms(:to_number => '1234')
mms = Mobile::Globe::MMS.new({:to_number => '5678'})
p mms.to_h
#puts client.send_mms(mms)

