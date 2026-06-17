# frozen_string_literal: true

module R2
  module Commands
    class DownloadFile
      def initialize(storage)
        @storage = storage
      end

      def call(key, path, options = {})
        resp = @storage.download(key, options)

        File.binwrite(path, resp.body.read)

        { key: key }
      end
    end
  end
end
