# frozen_string_literal: true

require 'thor'

module R2
  # R2 gem CLI.
  #
  # Command-line interface that delegates storage operations
  # to R2::Storage.
  class CLI < Thor
    class << self
      # Storage instance injected externally (e.g., bin/r2).
      # It is required for CLI execution.
      attr_accessor :storage
    end

    # Failures should terminate the process with a non-zero exit code.
    def self.exit_on_failure?
      true
    end

    # Default bucket used in operations.
    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    # Uploads a file to the configured bucket.
    #
    # Reads the entire file into memory before uploading.
    #
    # @param path [String] local file path
    desc 'upload PATH', 'Upload a file to R2'
    def upload(path)
      result = storage.upload(
        key: File.basename(path),
        bucket: options.fetch(:bucket),
        body: File.binread(path),
      )

      say("[R2] upload -> #{result[:key]}")
    end

    private

    # Access to the storage instance injected into the class.
    def storage
      self.class.storage
    end
  end
end
