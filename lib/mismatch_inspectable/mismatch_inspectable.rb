require_relative 'hash_formatter'
require_relative 'array_formatter'

module MismatchInspectable
  class << self
    def included(base)
      class << base
        include ClassMethods
      end
    end
  end

  module ClassMethods
    attr_reader :compare_methods

    def inspect_mismatch_for(*methods)
      @compare_methods = methods
    end
  end

  def inspect_mismatch(other, recursive: false, include_class: true, prefix: '', format: :array)
    return if self.class != other.class

    formatter = format == :hash ? HashFormatter.new : ArrayFormatter.new
    process_attributes(formatter, other, recursive, include_class, prefix, format)

    formatter.mismatches
  end

  def compare_methods
    self.class.compare_methods
  end

  private

  def process_attributes(formatter, other, recursive, include_class, prefix, format)
    self.class.compare_methods.each do |attribute|
      curr_val = __send__(attribute)
      other_val = other.__send__(attribute)

      if recursive && both_are_inspectable?(curr_val, other_val)
        process_recursive(formatter, curr_val, other_val, include_class, prefix, attribute, format)
      elsif curr_val != other_val
        prefix = update_prefix(include_class, prefix)
        formatter.add_mismatch(prefix, attribute, curr_val, other_val)
      end
    end
  end

  def both_are_inspectable?(curr_val, other_val)
    curr_val.respond_to?(:inspect_mismatch) && other_val.respond_to?(:inspect_mismatch)
  end

  def process_recursive(formatter, curr_val, other_val, include_class, prefix, attribute, format)
    prefix = update_prefix(include_class, prefix)
    nested_mismatches = curr_val.inspect_mismatch(
      other_val, recursive: true, include_class: include_class, prefix: prefix + "#{attribute}.", format: format
    )
    formatter.merge_mismatches(nested_mismatches)
  end

  def update_prefix(include_class, prefix)
    include_class ? "#{prefix}#{self.class}#" : prefix
  end
end
