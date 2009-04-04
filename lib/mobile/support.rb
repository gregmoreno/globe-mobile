module ClassUtilMixin
  def initialize(params = {})
    initialize_with(params)
  end

  def initialize_with(params = {})
    params.each do |k,v|
      self.send("#{k}=", v) if self.respond_to?(k)
    end
  end

  def to_hash_with(keys)
    h = {}
    keys.each do |k|
      h[k] = self.send(k) if self.respond_to?(k)
    end
    h
  end
end

