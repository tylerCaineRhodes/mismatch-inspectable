require_relative "hash_formatter"
require_relative "array_formatter"
require_relative "object_formatter"

module MismatchInspectable
  FormatBuilder = Struct.new(:format) do
    def formatter
      @formatter ||= select_formatter
    end

    private

    def select_formatter
      case format
      when :hash then HashFormatter.new
      when :array then ArrayFormatter.new
      when :object then ObjectFormatter.new
      else raise ArgumentError, "Invalid format: #{format}"
      end
    end
  end
end
