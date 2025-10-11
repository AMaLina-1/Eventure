require 'http'

module Eventure
  # 純 HTTP 請求
  class HttpRequest
    BASE = 'https://webopenapi.hccg.gov.tw'.freeze

    # 取得活動資料，回傳：HTTP::Response
    def self.get_hccg_activity(top: 100)
      url = "#{BASE}/v1/Activity?top=#{top}"

      res = HTTP.headers('Accept' => 'application/json',
                         'User-Agent' => 'Eventure/0.1').get(url)
      raise 'Request Failed' unless res.status.success?
      res
    end
  end
end