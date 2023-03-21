module MismatchInspectable
  class HashFormatter
    attr_reader :mismatches

    def initialize
      @mismatches = Hash.new { |hash, key| hash[key] = {} }
    end

    def add_mismatch(prefix, attribute, curr_val, other_val)
      @mismatches[prefix + attribute.to_s] = [curr_val, other_val]
    end

    def merge_mismatches(nested_mismatches)
      nested_mismatches.each { |k, v| mismatches[k] = v }
    end
  end
end
