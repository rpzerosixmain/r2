# frozen_string_literal: true

module R2
  module Commands
    class DeleteFile
      def initialize(storage)
        @storage = storage
      end

      def call(key, options = {})
        @storage.delete(key, options)

        { key: key }
      end
    end
  end
end
