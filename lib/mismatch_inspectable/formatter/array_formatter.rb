require_relative "formatter"

module MismatchInspectable
  class ArrayFormatter < Formatter
    attr_reader :mismatches

    def initialize
      super
      @mismatches = []
    end

    def add_mismatch(prefix, attribute, curr_val, other_val)
      @mismatches << [prefix + attribute.to_s, curr_val, other_val]
    end

    def process_mismatches(nested_mismatches)
      @mismatches.concat(nested_mismatches)
    end
  end
end
