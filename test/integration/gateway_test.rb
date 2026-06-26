# frozen_string_literal: true

require_relative '../test_helper'

class GatewayTest < Minitest::Test
  def setup
    @bucket = 'test-bucket'
    @storage = {}

    @client = FakeClient.new(@storage)
    @gateway = R2::Gateway.new(client: @client)

    @tmp_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry(@tmp_dir) if @tmp_dir && Dir.exist?(@tmp_dir)
  end

  def test_upload_and_list
    create_file('file.txt', 'data')

    @gateway.upload(
      path: file_path('file.txt'),
      options: { bucket: @bucket },
    )

    assert_equal ['file.txt'], list_keys
    assert_equal 'data', @storage[@bucket]['file.txt']
  end

  def test_download_writes_file_and_returns_body
    create_storage_file('file.txt', 'data')

    Dir.chdir(@tmp_dir) do
      result = @gateway.download(
        key: 'file.txt',
        options: { bucket: @bucket },
      )

      assert File.exist?('file.txt')
      assert_equal 'data', File.read('file.txt')
      assert_equal 'data', result.body
    end
  end

  def test_download_uses_custom_path
    create_storage_file('file.txt', 'data')

    Dir.chdir(@tmp_dir) do
      @gateway.download(
        key: 'file.txt',
        path: 'custom.txt',
        options: { bucket: @bucket },
      )

      assert File.exist?('custom.txt')
      assert_equal 'data', File.read('custom.txt')
    end
  end

  def test_delete_removes_object
    create_storage_file('file.txt', 'data')

    @gateway.delete(
      key: 'file.txt',
      options: { bucket: @bucket },
    )

    assert @storage[@bucket].empty?
  end

  def test_upload_uses_filename_as_key
    create_file('auto_key.txt', 'data')

    @gateway.upload(
      path: file_path('auto_key.txt'),
      options: { bucket: @bucket },
    )

    assert_equal 'data', @storage[@bucket]['auto_key.txt']
  end

  def test_missing_bucket_raises_error
    create_file('file.txt', 'data')

    assert_raises(KeyError) do
      @gateway.upload(path: file_path('file.txt'))
    end
  end

  private

  def file_path(name)
    File.join(@tmp_dir, name)
  end

  def create_file(name, content)
    File.write(file_path(name), content)
  end

  def create_storage_file(name, content)
    @storage[@bucket] ||= {}
    @storage[@bucket][name] = content
  end

  def list_keys
    @gateway.list(options: { bucket: @bucket })
            .contents
            .map(&:key)
  end
end
