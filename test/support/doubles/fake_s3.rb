# frozen_string_literal: true

class FakeS3
  attr_reader :bucket, :key, :body

  attr_accessor :error

  def put_object(bucket:, key:, body:)
    raise error if error

    @bucket = bucket
    @key = key
    @body = body
  end
end
