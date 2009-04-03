require 'mobile'

#client = Mobile::Globe::SOAP.configure do |config|
client = Mobile::Globe::REST.configure do |config|
  config.username = 'greg'
  config.pin = '1234'
end
#p client
puts client.send_sms
p client.send_mms
