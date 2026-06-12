# frozen_string_literal: true

module R2
  class Storage
    class Result
      attr_reader :key, :content, :size

      def initialize(key:, content: nil, size: nil)
        @key = key
        @content = content
        @size = size
      end
    end
  end
end
