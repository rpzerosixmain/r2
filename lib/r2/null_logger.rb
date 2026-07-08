# frozen_string_literal: true

module R2
  # Null Object logger that silently discards every message.
  #
  # Used as the default logger so callers can rely on a logger always being
  # present and drop nil checks (e.g. `logger&.info`).
  class NullLogger
    # Kept for API compatibility with ::Logger; reading/writing has no effect.
    attr_accessor :level

    %i[debug info warn error fatal unknown].each do |severity|
      define_method(severity) { |*_args| nil }
    end
  end
end
