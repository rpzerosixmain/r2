# frozen_string_literal: true

require_relative 'cli_test'



class CliErrorHandlingTest < CLITest
  def test_list_fails_for_nonexistent_bucket
    assert_failure(
      'list',
      '--bucket', "missing-#{SecureRandom.uuid}"
    )
  end

  def test_download_fails_for_nonexistent_object
    assert_failure(
      'download',
      "missing-#{SecureRandom.uuid}",
    )
  end
end
