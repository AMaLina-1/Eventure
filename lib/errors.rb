# frozen_string_literal: true

module HccgEventure
  class HTTPError < StandardError
    attr_reader :status, :body
    def initialize(message = 'HTTP error', status: nil, body: nil)
      super(message)
      @status = status
      @body   = body
    end
  end
end
