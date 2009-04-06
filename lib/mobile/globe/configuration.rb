module Mobile::Globe::Configuration

  def self.append_features(klass)
    def klass.configure(&block)
      config = self.new
      raise ArgumentError, "Block must be provided to configure" unless block_given?
      yield config

      [:user_name, :user_pin].each do |required|
        raise "#{required} must be configured" unless config.send(required)  
      end
      config
    end
    super
  end

end
