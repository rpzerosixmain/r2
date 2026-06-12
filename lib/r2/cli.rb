# frozen_string_literal: true

require 'thor'

require_relative 'storage'

module R2
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    class_option :prefix,
                 aliases: '-p',
                 default: nil,
                 desc: 'Object prefix (virtual folder)'

    desc 'upload KEY', 'Upload a file to R2'
    def upload(key)
      result = storage.upload(
        bucket: bucket,
        key: key,
        body: read_file(key),
        prefix: prefix,
      )

      say "[R2] Uploaded: #{result.key} (#{result.size} bytes)"
    end

    desc 'download KEY', 'Download a file from R2'
    def download(key)
      result = storage.download(
        bucket: bucket,
        key: key,
        prefix: prefix,
      )

      write_file(key, result.content)

      say "[R2] Downloaded: #{result.key} (#{result.size} bytes)"
    end

    desc 'delete KEY', 'Remove a file from R2'
    def delete(key)
      result = storage.delete(
        bucket: bucket,
        key: key,
        prefix: prefix,
      )

      say "[R2] Deleted: #{result.key}"
    end

    desc 'list', 'List files in R2 bucket'
    def list
      results = storage.list(
        bucket: bucket,
        prefix: prefix,
      )

      results.each do |result|
        say "[R2] #{result.key} (#{result.size} bytes)"
      end
    end

    private

    def bucket
      options[:bucket]
    end

    def prefix
      options[:prefix]
    end

    def read_file(path)
      File.binread(path)
    end

    def write_file(path, content)
      File.binwrite(path, content)
    end

    def storage
      @storage ||= R2::Storage.build
    end
  end
end
