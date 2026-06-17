# frozen_string_literal: true

module R2
  module Commands
    class ListFiles
      def initialize(storage)
        @storage = storage
      end

      def call(options = {})
        resp = @storage.list(options)

        {
          items: resp.contents.map do |item|
            {
              key: item.key,
              size: item.size,
            }
          end,
        }
      end
    end
  end
end
