# frozen_string_literal: true

require_relative '../test_helper'

class CLITest < Minitest::Test
  def setup
    @storage = FakeStorage.new
    R2::CLI.storage = @storage
    R2::CLI.logger = nil
  end

  def teardown
    R2::CLI.logger = nil
  end

  def test_upload_stores_file_and_outputs_result
    Tempfile.create(['example', '.txt']) do |file|
      file.binmode
      file.write('hello world')
      file.flush

      capture_io do
        R2::CLI.start(['upload', file.path])
      end

      assert_equal 'main', @storage.bucket
      assert_equal File.basename(file.path), @storage.key
      assert_equal 'hello world', @storage.body
    end
  end

  def test_upload_raises_file_error_when_missing
    error = assert_raises(R2::FileError) do
      capture_io do
        R2::CLI.start(['upload', '/no/such/file.txt'])
      end
    end

    assert_match(/file not found/, error.message)
  end

  def test_upload_raises_file_error_for_directory
    Dir.mktmpdir do |dir|
      error = assert_raises(R2::FileError) do
        capture_io do
          R2::CLI.start(['upload', dir])
        end
      end

      assert_match(/not a file/, error.message)
    end
  end

  def test_upload_with_custom_bucket
    Tempfile.create(['example', '.txt']) do |file|
      file.binmode
      file.write('hello world')
      file.flush

      capture_io do
        R2::CLI.start(['upload', file.path, '--bucket', 'images'])
      end

      assert_equal 'images', @storage.bucket
      assert_equal File.basename(file.path), @storage.key
      assert_equal 'hello world', @storage.body
    end
  end

  def test_verbose_lowers_log_level_and_logs
    output = StringIO.new
    logger = build_logger(output)
    R2::CLI.logger = logger

    with_upload(['--verbose'])

    assert_equal Logger::INFO, logger.level
    assert_match(/uploading/, output.string)
    assert_match(/uploaded/, output.string)
  end

  def test_without_verbose_keeps_error_level_and_is_quiet
    output = StringIO.new
    logger = build_logger(output)
    R2::CLI.logger = logger

    with_upload([])

    assert_equal Logger::ERROR, logger.level
    assert_empty output.string
  end

  private

  def build_logger(output)
    logger = Logger.new(output)
    logger.level = Logger::ERROR
    logger
  end

  def with_upload(extra_args)
    Tempfile.create(['example', '.txt']) do |file|
      file.write('hello world')
      file.flush

      capture_io do
        R2::CLI.start(['upload', file.path, *extra_args])
      end
    end
  end
end
