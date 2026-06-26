# frozen_string_literal: true

class FakeClient
  def initialize(storage)
    @storage = storage
  end

  def upload(key:, bucket:, body:)
    @storage[bucket] ||= {}
    @storage[bucket][key] = body
    true
  end

  def download(key:, bucket:)
    Struct.new(:body).new(@storage.dig(bucket, key))
  end

  def delete(key:, bucket:)
    @storage[bucket].delete(key)
    true
  end

  def list(bucket:)
    keys = (@storage[bucket] || {}).keys

    Struct.new(:contents).new(
      keys.map { |k| Struct.new(:key).new(k) },
    )
  end
end
