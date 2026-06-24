# frozen_string_literal: true

require 'thor'
require 'logger'

require_relative 'cli/gateway'

module R2
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    class_option :bucket,
                 aliases: '-b',
                 default: 'main',
                 desc: 'R2 bucket name'

    class_option :verbose,
                 type: :boolean,
                 default: false,
                 desc: 'Show detailed logs'

    desc 'upload PATH [KEY]', 'Upload a file to R2'
    def upload(path, key = nil)
      result = gateway.upload(
        path: path,
        key: key,
        options: options,
      )

      say("[R2] uploaded: #{result.key}")
    end

    desc 'download KEY [PATH]', 'Download a file from R2'
    def download(key, path = nil)
      result = gateway.download(
        key: key,
        path: path,
        options: options,
      )

      say("[R2] downloaded: #{result.key}")
    end

    desc 'delete KEY', 'Remove a file from R2'
    def delete(key)
      result = gateway.delete(
        key: key,
        options: options,
      )

      say("[R2] deleted: #{result.key}")
    end

    desc 'list', 'List files in R2 bucket'
    def list
      items = gateway.list(options: options)

      if items.empty?
        say('[R2] bucket is empty')
        return
      end

      items.each do |item|
        say("[R2] #{item.key} (etag: #{item.etag})")
      end
    end

    private

    def gateway
      @gateway ||= R2::CLI::Gateway.new(client: client)
    end

    def client
      @client ||= R2::Client.new(
        access_key_id: ENV.fetch('R2_ACCESS_KEY_ID'),
        secret_access_key: ENV.fetch('R2_SECRET_ACCESS_KEY'),
        endpoint: ENV.fetch('R2_ENDPOINT'),
        region: ENV.fetch('R2_REGION', 'auto'),
        logger: logger
      )
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |logger|
        logger.level = options[:verbose] ? Logger::INFO : Logger::FATAL

        logger.formatter = proc do |_severity, _datetime, _progname, msg|
          "[R2] #{msg}\n"
        end
      end
    end
  end
end