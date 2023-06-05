require_relative "formatter/format_builder"

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
      @formatter ||= FormatBuilder.new(format).formatter
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
  end
end
