# frozen_string_literal: true

module R2
  module Storage
    class Config
      attr_reader :access_key_id, :secret_access_key, :endpoint, :region

      def self.from_env
        new(
          access_key_id: ENV.fetch('R2_ACCESS_KEY_ID'),
          secret_access_key: ENV.fetch('R2_SECRET_ACCESS_KEY'),
          endpoint: ENV.fetch('R2_ENDPOINT'),
          region: ENV.fetch('R2_REGION', 'auto'),
        )
      end

      def initialize(access_key_id:, secret_access_key:, endpoint:, region: 'auto')
        @access_key_id     = access_key_id
        @secret_access_key = secret_access_key
        @endpoint          = endpoint
        @region            = region

        validate!
      end

      private

      def validate!
        missing = []
        missing << 'access_key_id'     if blank?(@access_key_id)
        missing << 'secret_access_key' if blank?(@secret_access_key)
        missing << 'endpoint'          if blank?(@endpoint)

        return if missing.empty?

        raise ArgumentError, "[R2] Missing credentials: #{missing.join(', ')}"
      end

      def blank?(value)
        value.nil? || value.to_s.strip.empty?
      end
    end
  end
end
