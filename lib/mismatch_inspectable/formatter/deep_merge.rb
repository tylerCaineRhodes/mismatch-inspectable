module DeepMerge
  def deep_merge!(other_hash)
    other_hash&.each do |key, value|
      if self[key].is_a?(Hash) && value.is_a?(Hash)
        self[key].extend(DeepMerge) unless self[key].respond_to?(:deep_merge!)
        self[key].deep_merge!(value)
      else
        self[key] = value
      end
    end
    self
  end
end
