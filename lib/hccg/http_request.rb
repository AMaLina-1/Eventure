# frozen_string_literal: true

require 'http'

module Eventure
  # Simple HTTP client for HCCG API.
  #
  # Responsibilities:
  # - build the request URL
  # - set default headers
  # - return the HTTP response or raise on non-success
  class HttpClient
    BASE = 'https://webopenapi.hccg.gov.tw'

    def initialize(base: BASE, user_agent: 'Eventure/0.1', http: HTTP)
      @base = base
      @user_agent = user_agent
      @http = http
    end

    def get_hccg_activity(top: 100)
      url = "#{@base}/v1/Activity?top=#{top}"

      res = @http.headers('Accept' => 'application/json', 'User-Agent' => @user_agent).get(url)
      raise 'Request Failed' unless res.status.success?

      res
    end
  end
end
