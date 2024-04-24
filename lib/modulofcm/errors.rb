# frozen_string_literal: true

module Modulofcm

  class Error < StandardError; end

  class InvalidClient < Error

    def initialize(msg=nil)
      super(msg.presence || 'Invalid client configuration')
    end

  end

  class NoTokenError < Error

    def initialize
      super('Token required to send a notification')
    end

  end

  class EmptyNotificationError < Error

    def initialize
      super('A data payload, a title or a body is required to send a notification')
    end

  end

end
