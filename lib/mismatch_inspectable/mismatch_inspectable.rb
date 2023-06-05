require_relative "inspection_options"

module MismatchInspectable
  attr_reader :options

  def self.included(target_class)
    target_class.extend ClassMethods
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

  def inspect_mismatch(other, **options)
    @options ||= InspectionOptions.new(**options)
    find_mismatches(other)
  end

  protected

  def find_mismatches(other)
    return if self.class != other.class

    process_attributes!(other)
    mismatches
  end

  private

  def compare_methods
    self.class.compare_methods
  end

  def process_attributes!(other)
    raise MissingCompareMethodsError if compare_methods.nil?

    compare_methods.each do |attribute|
      curr_val = __send__(attribute)
      other_val = other.__send__(attribute)

      if options.recursive && both_are_inspectable?(curr_val:, other_val:)
        process_recursive(curr_val:, other_val:, attribute:)
      elsif curr_val != other_val

        update_prefix(target_class: self)
        formatter.add_mismatch(options.prefix, attribute, curr_val, other_val)
      end
    end
  end

  def both_are_inspectable?(curr_val:, other_val:)
    curr_val.respond_to?(:inspect_mismatch) && other_val.respond_to?(:inspect_mismatch)
  end

  def process_recursive(curr_val:, other_val:, attribute:)
    options.prefix = "#{options.prefix}#{attribute}."
    options.recursive = true
    nested_mismatches = curr_val.inspect_mismatch(
      other_val,
      **options.to_h
    )
    merge_mismatches(nested_mismatches:) unless no_nested_mismatches?(nested_mismatches)
  end

  def no_nested_mismatches?(mismatches)
    mismatches.nil? || mismatches.empty?
  end

  def update_prefix(target_class:)
    options.update_prefix(target_class)
  end

  def formatter
    options.formatter
  end

  def mismatches
    formatter.mismatches
  end

  def merge_mismatches(nested_mismatches:)
    formatter.merge_mismatches(nested_mismatches)
  end
end
