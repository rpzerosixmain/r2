# frozen_string_literal: true

require_relative '../test_helper'
class R2GatewayTest < Minitest::Test
  def setup
    @bucket = 'test-bucket'
    @storage = {}

    @client = fake_client(@storage)
    @gateway = R2::Gateway.new(client: @client)
  end

  def fake_client(storage)
    Class.new do
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
        keys = @storage[bucket].keys

        Struct.new(:contents).new(
          keys.map { |k| Struct.new(:key).new(k) },
        )
      end
    end.new(storage)
  end

  def test_full_lifecycle_upload_list_download_delete
    Dir.mktmpdir do |dir|
      file_path = File.join(dir, 'file.txt')
      File.write(file_path, 'hello integration')

      @gateway.upload(
        path: file_path,
        options: { bucket: @bucket },
      )

      assert_equal 'hello integration', @storage[@bucket]['file.txt']

      list_result = @gateway.list(options: { bucket: @bucket })
      keys = list_result.contents.map(&:key)

      assert_equal ['file.txt'], keys

      Dir.chdir(dir) do
        result = @gateway.download(
          key: 'file.txt',
          options: { bucket: @bucket },
        )

        assert_equal 'hello integration', File.read('file.txt')
        assert_equal 'hello integration', result.body
      end

      @gateway.delete(
        key: 'file.txt',
        options: { bucket: @bucket },
      )

      assert @storage[@bucket].empty?
    end
  end

  def test_upload_uses_filename_as_key
    Dir.mktmpdir do |dir|
      file_path = File.join(dir, 'auto_key.txt')
      File.write(file_path, 'data')

      @gateway.upload(
        path: file_path,
        options: { bucket: @bucket },
      )

      assert_equal 'data', @storage[@bucket]['auto_key.txt']
    end
  end

  def test_download_without_path_writes_to_current_directory
    Dir.mktmpdir do |dir|
      @storage[@bucket] = {
        'file.txt' => 'hello current dir',
      }

      Dir.chdir(dir) do
        result = @gateway.download(
          key: 'file.txt',
          options: { bucket: @bucket },
        )

        assert File.exist?('file.txt')
        assert_equal 'hello current dir', File.read('file.txt')
        assert_equal 'hello current dir', result.body
      end
    end
  end
end
