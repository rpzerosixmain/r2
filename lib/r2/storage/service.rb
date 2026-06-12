# frozen_string_literal: true

require 'aws-sdk-s3'

require_relative 'result'

module R2
  class Storage
    class Service
      def initialize(config:)
        @s3 = Aws::S3::Client.new(
          access_key_id: config.access_key_id,
          secret_access_key: config.secret_access_key,
          endpoint: config.endpoint,
          region: config.region,
          force_path_style: true,
          http_open_timeout: 15,
          http_read_timeout: 60,
        )
      end

      def put(bucket:, key:, body:, prefix: nil)
        object_key = build_key(prefix, key)

        @s3.put_object(
          bucket: bucket,
          key: object_key,
          body: body,
          size: body.bytesize,
        )

        Result.new(key: object_key, size: body.bytesize)
      end

      def get(bucket:, key:, prefix: nil)
        object_key = build_key(prefix, key)

        resp = @s3.get_object(
          bucket: bucket,
          key: object_key,
        )

        Result.new(key: object_key, content: resp.body.read, size: resp.content_length)
      end

      def delete(bucket:, key:, prefix: nil)
        object_key = build_key(prefix, key)

        @s3.delete_object(
          bucket: bucket,
          key: object_key,
        )

        Result.new(key: object_key)
      end

      def list(bucket:, prefix: nil)
        resp = @s3.list_objects_v2(
          bucket: bucket,
          prefix: prefix,
        )

        resp.contents.map do |object|
          Result.new(
            key: object.key,
            size: object.size,
          )
        end
      end

      private

      def build_key(prefix, key)
        [prefix, key.to_s.strip]
          .compact
          .reject(&:empty?)
          .join('/')
      end
    end
  end
end
