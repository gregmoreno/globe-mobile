module Mobile::Globe
  class Response; end
  class SMS; end
  class MMS; end
  module SOAP; end
  module REST; end
  module Callback; end
end
require_local 'mobile/globe/response'
require_local 'mobile/globe/models'
require_local 'mobile/globe/soap'
require_local 'mobile/globe/rest'
require_local 'mobile/globe/callback'


# TODO: create an SMS class with expected fields that can trasform itself to globe's names
# that behaves like a hash
