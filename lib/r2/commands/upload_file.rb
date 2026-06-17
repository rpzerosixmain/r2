# frozen_string_literal: true

module R2
  module Commands
    class UploadFile
      def initialize(storage)
        @storage = storage
      end

      def call(key, path, options = {})
        body = File.binread(path)

        @storage.upload(key, body, options)

        { key: key }
      end
    end
  end
end
