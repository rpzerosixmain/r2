# frozen_string_literal: true

class FakeStorage
  attr_reader :bucket, :key, :body

  def upload(bucket:, key:, body:)
    @bucket = bucket
    @key = key
    @body = body

    { key: key }
  end
end
