# frozen_string_literal: true

require_relative '../test_helper'

class ClientnTest < Minitest::Test
  BUCKET = ENV.fetch('R2_BUCKET_TEST')
  INVALID_BUCKET = 'invalid-bucket'
  MISSING_KEY = 'missing-key'

  def setup
    @client = build_client
    @key = "integration/#{SecureRandom.hex(8)}"
  end

  def test_upload_returns_result
    result = upload_fixture
    assert_result(result)
  end

  def test_download_returns_result
    upload_fixture

    result = @client.download(bucket: BUCKET, key: @key)

    assert_result(result)
  end

  def test_delete_returns_result
    upload_fixture

    result = @client.delete(bucket: BUCKET, key: @key)

    assert_result(result)
  end

  def test_list_returns_array_of_results
    result = @client.list(bucket: BUCKET)

    assert_instance_of Array, result
    assert(result.all?(R2::Client::Result))
  end

  def test_upload_raises_r2_error_for_invalid_bucket
    assert_r2_error do
      @client.upload(bucket: INVALID_BUCKET, key: @key, body: 'data')
    end
  end

  def test_download_raises_r2_error_for_missing_key
    assert_r2_error do
      @client.download(bucket: BUCKET, key: MISSING_KEY)
    end
  end

  def test_list_raises_r2_error_for_invalid_bucket
    assert_r2_error do
      @client.list(bucket: INVALID_BUCKET)
    end
  end

  def test_delete_raises_r2_error_for_invalid_bucket
    assert_r2_error do
      @client.delete(bucket: INVALID_BUCKET, key: @key)
    end
  end

  private

  def build_client
    R2::Client.new(
      access_key_id: ENV.fetch('R2_ACCESS_KEY_ID_TEST'),
      secret_access_key: ENV.fetch('R2_SECRET_ACCESS_KEY_TEST'),
      endpoint: ENV.fetch('R2_ENDPOINT_TEST'),
      region: ENV.fetch('R2_REGION_TEST', 'auto'),
    )
  end

  def upload_fixture
    @client.upload(bucket: BUCKET, key: @key, body: 'data')
  end

  def assert_result(result)
    assert_instance_of R2::Client::Result, result
  end

  def assert_r2_error(&)
    assert_raises(R2::Error, &)
  end
end
