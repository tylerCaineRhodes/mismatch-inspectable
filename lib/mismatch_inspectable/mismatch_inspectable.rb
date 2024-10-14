require_relative "inspection_options"

module MismatchInspectable
  def self.diff(obj1, obj2, path = "")
    differences = []

    case obj1
    when Hash
      all_keys = obj1.keys | obj2.keys
      all_keys.each do |key|
        new_path = path.empty? ? key.to_s : "#{path}.#{key}"
        unless obj1.key?(key) && obj2.key?(key)
          differences << "Key present only in one object: '#{new_path}'"
          next
        end
        differences.concat(diff(obj1[key], obj2[key], new_path))
      end
    when Array
      max_length = [obj1.length, obj2.length].max
      (0...max_length).each do |index|
        new_path = "#{path}[#{index}]"
        if index >= obj1.length || index >= obj2.length
          differences << ["#length", obj1.length, obj2.length]
        else
          differences.concat(diff(obj1[index], obj2[index], new_path))
        end
      end
    else
      unless obj1 == obj2
        differences << [path, obj1, obj2]
      end
    end

    differences
  end

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

  def inspect_mismatch(other_klass, **options)
    @options ||= InspectionOptions.new(**options)

    find_mismatches(other_klass:)
  end

  protected

  def find_mismatches(other_klass:)
    return if self.class != other_klass.class

    process_attributes!(other_klass:)
    mismatches
  end

  private

  def compare_methods
    self.class.compare_methods
  end

  def process_attributes!(other_klass:)
    raise MissingCompareMethodsError if compare_methods.nil?

    compare_methods.each do |attribute|
      curr_val = __send__(attribute)
      other_val = other_klass.__send__(attribute)

      if options.recursive && both_are_inspectable?(curr_val:, other_val:)
        process_recursive!(curr_val:, other_val:, attribute:)
      elsif curr_val != other_val

        update_prefix(target_class: self)
        formatter.add_mismatch(options.prefix, attribute, curr_val, other_val)
      end
    end
  end

  def both_are_inspectable?(curr_val:, other_val:)
    curr_val.respond_to?(:inspect_mismatch) && other_val.respond_to?(:inspect_mismatch)
  end

  def process_recursive!(curr_val:, other_val:, attribute:)
    options.prefix = "#{options.prefix}#{attribute}."
    options.recursive = true
    nested_mismatches = curr_val.inspect_mismatch(
      other_val,
      **options.to_h
    )
    merge_mismatches(nested_mismatches:)
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
