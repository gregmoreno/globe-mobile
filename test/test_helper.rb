require 'yaml'
require File.dirname(__FILE__) + '/../lib/mobile'

# Config file should have the ff: values
# :user_name: value
# :user_pin: value
def from_config
  config ||= YAML::load(File.open((File.join(File.dirname(__FILE__), 'config.yml'))))
end

