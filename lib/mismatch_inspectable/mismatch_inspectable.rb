require_relative 'hash_formatter'
require_relative 'array_formatter'
require_relative 'object_formatter'

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

  class MissingCompareMethodsError < StandardError
    def initialize(klass)
      super("The class #{klass} does not have methods to compare. Define methods with `inspect_mismatch_for`.")
    end
  end

  def inspect_mismatch(other, recursive: false, include_class: true, prefix: '', format: :array)
    return if self.class != other.class

    formatter = select_formatter(format)

    process_attributes(formatter, other, recursive, include_class, prefix, format)
    formatter.mismatches
  end

  def compare_methods
    self.class.compare_methods
  end

  private

  def select_formatter(format)
    case format
    when :hash then HashFormatter.new
    when :array then ArrayFormatter.new
    when :object then ObjectFormatter.new
    else raise ArgumentError, "Invalid format: #{format}"
    end
  end

  def process_attributes(formatter, other, recursive, include_class, prefix, format)
    raise MissingCompareMethodsError if compare_methods.nil?

    compare_methods.each do |attribute|
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
    nested_mismatches = curr_val.inspect_mismatch(
      other_val,
      recursive: true,
      include_class: include_class,
      prefix: "#{prefix}#{attribute}.",
      format: format
    )

    formatter.merge_mismatches(nested_mismatches) unless no_nested_mismatches?(nested_mismatches)
  end

  def update_prefix(include_class, prefix)
    comparable_prefix = get_comparable_prefix(prefix)
    include_class && comparable_prefix != "#{self.class}#" ? "#{prefix}#{self.class}#" : prefix
  end

  def no_nested_mismatches?(mismatches)
    mismatches.nil? || mismatches.empty?
  end

  def get_comparable_prefix(prefix)
    prefixes = prefix.split('.')
    prefixes.length >= 2 ? prefixes[-1] : prefix
  end
end
