# frozen_string_literal: true

require 'tempfile'
require 'open3'
require 'securerandom'
require 'minitest/autorun'

class CliTest < Minitest::Test
  BIN = [RbConfig.ruby, 'exe/r2'].freeze

  def setup
    @keys_to_cleanup = []
  end

  def teardown
    @keys_to_cleanup.each { |key| run_cmd_silently('delete', key) }
  end

  def test_list
    assert_success 'list'
  end

  def test_upload
    key = unique_key

    with_fixture_file do |file_path|
      assert_success 'upload', key, file_path
    end
  end

  def test_download
    key = unique_key
    original_content = fixture_content

    with_fixture_file do |upload_path|
      assert_success 'upload', key, upload_path
    end

    with_temp_file do |download_path|
      assert_success 'download', key, download_path
      assert_equal original_content, File.read(download_path)
    end
  end

  def test_delete
    key = unique_key

    with_fixture_file do |file_path|
      assert_success 'upload', key, file_path
    end

    assert_success 'delete', key
  end

  private

  def fixture_content
    @fixture_content ||= File.read('test/fixtures/test-file.txt')
  end

  def unique_key
    key = "test/#{SecureRandom.uuid}"
    @keys_to_cleanup << key
    key
  end

  def assert_success(*args)
    status = run_cmd(*args)
    assert status.success?, "Command failed: #{args.join(' ')}"
  end

  def run_cmd(*)
    _stdout, _stderr, status = Open3.capture3(*BIN, *)
    status
  end

  def run_cmd_silently(*)
    Open3.capture3(*BIN, *)
  end

  def with_fixture_file(&)
    with_temp_file(fixture_content, &)
  end

  def with_temp_file(content = nil, ext: '.tmp')
    Tempfile.create(['r2-test', ext]) do |file|
      file.write(content) if content
      file.flush
      file.rewind
      yield file.path
    end
  end
end
