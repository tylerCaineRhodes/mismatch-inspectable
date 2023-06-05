require_relative "hash_formatter"
require_relative "array_formatter"
require_relative "object_formatter"

module MismatchInspectable
  class InspectionOptions
    attr_accessor :recursive, :include_class, :prefix, :format, :options

    def initialize(prefix: "", recursive: false, include_class: true, format: :array)
      @recursive = recursive
      @include_class = include_class
      @prefix = prefix
      @format = format
    end

    def formatter
      @formatter ||= select_formatter(@format)
    end

    def to_h
      {
        recursive:,
        include_class:,
        prefix:,
        format:
      }
    end

    def update_prefix(target_class)
      if include_class && comparable_prefix != "#{target_class.class}#"
        self.prefix = "#{prefix}#{target_class.class}#"
      end
    end

    def comparable_prefix
      prefixes = prefix.split(".")
      prefixes.length >= 2 ? prefixes[-1] : prefix
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
  end
end
