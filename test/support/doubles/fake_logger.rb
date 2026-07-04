# frozen_string_literal: true

class FakeLogger
  attr_reader :message

  def error(message)
    @message = message
  end
end
