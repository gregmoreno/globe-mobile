module Mobile::Globe

  class SMS
    include ClassUtilMixin  

    @@ATTRIBUTES = [
      :MSISDN,
      :messageString,
      :Display,
      :udh,
      :mwi,
      :coding
    ]
    attr_accessor *@@ATTRIBUTES

    @@DEFAULT_VALUES = {
      :to_number => '',
      :message   => '',
      :display   => '1',
      :user_data_header => '',
      :message_waiting_indicator => '',
      :coding    => '0'
    }

    def initialize(params={})
      initialize_with(@@DEFAULT_VALUES.merge(params))
    end

    def to_h
      to_hash_with(@@ATTRIBUTES)
    end

    # The ATTRIBUTES are names defined in the original API
    # We created aliases because it we really can't remember what MSISDN is for, really.

    {:to_number => :MSISDN,
     :message   => :messageString,
     :display   => :Display,
     :user_data_header => :udh,
     :message_waiting_indicator => :mwi
    }.each do |k, v|
      class_eval <<-RUBY
        alias_method :#{k},  :#{v} 
        alias_method :#{k}=, :#{v}=
      RUBY
    end
  end

  class MMS
    include ClassUtilMixin  

    @@ATTRIBUTES = [
      :MSISDN,
      :subject,
      :body
    ]
    attr_accessor *@@ATTRIBUTES

    @@DEFAULT_VALUES = {
      :to_number => '',
      :subject => '',
      :body => ''
    }

    def initialize(params={})
      initialize_with(@@DEFAULT_VALUES.merge(params))
    end

    def to_h
      to_hash_with(@@ATTRIBUTES)
    end
    
    {:to_number => :MSISDN,
    }.each do |k, v|
      class_eval <<-RUBY
        alias_method :#{k},  :#{v} 
        alias_method :#{k}=, :#{v}=
      RUBY
    end
  end

end
