module MismatchInspectable
  class Formatter
    attr_reader :mismatches

    def add_mismatch(prefix, attribute, curr_val, other_val)
      raise NotImplementedError
    end

    def merge_mismatches(nested_mismatches)
      process_mismatches(nested_mismatches) unless no_nested_mismatches?(nested_mismatches)
    end

    private

    def no_nested_mismatches?(mismatches)
      mismatches.nil? || mismatches.empty?
    end

    def process_mismatches(_nested_mismatches)
      raise NotImplementedError
    end
  end
end
