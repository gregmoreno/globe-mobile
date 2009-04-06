module Mobile::Globe

  class SMS 
    include ClassUtilMixin  

    set_default_attributes :MSISDN => '',
      :messageString => '',
      :Display => '1',
      :udh => '',
      :mwi => '',
      :coding => '0'
    
    # The ATTRIBUTES are names defined in the original API
    # We created aliases because it we really can't remember what MSISDN is for, really.

    set_attribute_aliases :to_number => :MSISDN,
     :message => :messageString,
     :display => :Display,
  end

  class MMS
    include ClassUtilMixin  

    set_default_attributes :MSISDN => '',
      :subject => '',
      :body => ''

    set_attribute_aliases :to_number => :MSISDN
  end

end
