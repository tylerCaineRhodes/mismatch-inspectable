require_relative "formatter"

module MismatchInspectable
  class HashFormatter < Formatter
    attr_reader :mismatches

    def initialize
      super
      @mismatches = Hash.new { |hash, key| hash[key] = {} }
    end

    def add_mismatch(prefix, attribute, curr_val, other_val)
      @mismatches[prefix + attribute.to_s] = [curr_val, other_val]
    end

    def process_mismatches(nested_mismatches)
      nested_mismatches.each { |k, v| mismatches[k] = v }
    end
  end
end
