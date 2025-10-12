# frozen_string_literal: true

require 'http'

module Eventure
  # Handles HTTP requests
  class HttpClient
    BASE = 'https://webopenapi.hccg.gov.tw'

    def initialize(base: BASE, user_agent: 'Eventure/0.1', http: HTTP)
      @base = base
      @user_agent = user_agent
      @http = http
    end

    # 取得活動資料（不支援 page 分頁）
    # 回傳：HTTP::Response
    def get_hccg_activity(top: 100)
      url = "#{@base}/v1/Activity?top=#{top}"

      res = @http.headers('Accept' => 'application/json', 'User-Agent' => @user_agent).get(url)
      raise 'Request Failed' unless res.status.success?

      res
    end
  end
end
