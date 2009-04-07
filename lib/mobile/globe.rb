module Mobile::Globe
  class Response; end
  class SMS; end
  class MMS; end
  module Configuration; end
  module SOAP; end
  module REST; end
  module Callback; end
end
require_local 'mobile/globe/response'
require_local 'mobile/globe/models'
require_local 'mobile/globe/config'
require_local 'mobile/globe/soap'
require_local 'mobile/globe/rest'
require_local 'mobile/globe/callback'
