# frozen_string_literal: true

require 'http'

module Eventure
  module Hccg
    # library for hccg activity api
    class Api
      #   PATH = "https://webopenapi.hccg.gov.tw/v1/Activity?top=#{@top}"

      def initialize
        @path = 'https://webopenapi.hccg.gov.tw/v1/Activity?top='
      end

      # return parsed json
      def parsed_json(top)
        Request.new.get(@path + top.to_s).parse
      end

      # use 'top' to get http response
      class Request
        def get(url)
          http_response = HTTP.headers('Accept' => 'application/json').get(url)
          raise 'Request Failed' unless http_response.status.success?

          http_response
        end
      end
    end
  end
end
