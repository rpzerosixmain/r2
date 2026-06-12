# frozen_string_literal: true

require 'logger'

require_relative 'storage/config'
require_relative 'storage/result'
require_relative 'storage/service'

module R2
  class Storage
    def initialize(service:, logger: nil)
      @service = service
      @logger = logger || default_logger
    end

    def upload(**args)
      execute { @service.put(**args) }
    end

    def download(**args)
      execute { @service.get(**args) }
    end

    def delete(**args)
      execute { @service.delete(**args) }
    end

    def list(**args)
      execute { @service.list(**args) }
    end

    def self.build(logger: nil)
      new(
        service: Service.new(config: Config.from_env),
        logger: logger,
      )
    end

    private

    def execute
      yield
    rescue StandardError => e
      @logger.error("#{e.class}: #{e.message}")
      raise
    end

    def default_logger
      Logger.new($stdout, level: Logger::INFO)
    end
  end
end
