module MismatchInspectable
  class ArrayFormatter
    attr_reader :mismatches

    def initialize
      @mismatches = []
    end

    def add_mismatch(prefix, attribute, curr_val, other_val)
      @mismatches << [prefix + attribute.to_s, curr_val, other_val]
    end

    def merge_mismatches(nested_mismatches)
      @mismatches.concat(nested_mismatches)
    end
  end
end
