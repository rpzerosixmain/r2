# frozen_string_literal: true

module R2
  module Storage
    class Download
      def initialize(client)
        @client = client
      end

      def call(key, options = {})
        @client.get_object(
          bucket: options[:bucket],
          key: key,
        )
      end
    end
  end
end
