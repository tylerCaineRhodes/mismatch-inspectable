require_relative "deep_merge"

class ObjectFormatter
  def initialize
    @mismatches = {}.extend(DeepMerge)
  end

  attr_reader :mismatches

  def add_mismatch(prefix, attribute, curr_val, other_val)
    prefix_parts = prefix.split(".").flat_map { |part| part.split("#") }.collect(&:to_sym)
    curr = mismatches

    prefix_parts.each do |part|
      curr[part] ||= {}
      curr = curr[part]
    end

    curr[attribute] = [curr_val, other_val]
  end

  def merge_mismatches(nested_mismatches)
    mismatches.deep_merge!(nested_mismatches)
  end
end
