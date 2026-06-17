# frozen_string_literal: true

module R2
  module Storage
    class List
      def initialize(client)
        @client = client
      end

      def call(options = {})
        @client.list_objects_v2(
          bucket: options[:bucket],
          prefix: options[:prefix],
        )
      end
    end
  end
end
