# frozen_string_literal: true

require_relative '../test_helper'

class StorageTest < Minitest::Test
  def setup
    @s3 = FakeS3.new
    @logger = FakeLogger.new

    @storage = R2::Storage.new(
      access_key_id: 'key',
      secret_access_key: 'secret',
      endpoint: 'http://localhost',
      s3: @s3,
      logger: @logger,
    )
  end

  def test_upload_delegates_to_s3_and_returns_key
    result = @storage.upload(
      bucket: 'bucket',
      key: 'file.txt',
      body: 'content',
    )

    assert_equal 'bucket', @s3.bucket
    assert_equal 'file.txt', @s3.key
    assert_equal 'content', @s3.body

    assert_equal({ key: 'file.txt' }, result)
  end

  def test_upload_raises_r2_error
    @s3.error = Aws::S3::Errors::NoSuchBucket.new(nil, 'Bucket not found')

    error = assert_raises(R2::Error) do
      @storage.upload(
        bucket: 'bucket',
        key: 'file.txt',
        body: 'content',
      )
    end

    assert_equal 'Bucket not found', error.message
  end

  def test_upload_logs_error
    @s3.error = Aws::S3::Errors::NoSuchBucket.new(nil, 'Bucket not found')

    assert_raises(R2::Error) do
      @storage.upload(
        bucket: 'bucket',
        key: 'file.txt',
        body: 'content',
      )
    end

    assert_equal 'Bucket not found', @logger.message
  end
end
