# frozen_string_literal: true

require_relative '../test_helper'

class NullLoggerTest < Minitest::Test
  def setup
    @logger = R2::NullLogger.new
  end

  def test_severity_methods_are_no_ops
    %i[debug info warn error fatal unknown].each do |severity|
      assert_nil @logger.public_send(severity, 'message')
    end
  end

  def test_level_is_settable_and_readable
    @logger.level = Logger::INFO

    assert_equal Logger::INFO, @logger.level
  end
end
