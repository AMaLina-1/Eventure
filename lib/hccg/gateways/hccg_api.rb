# frozen_string_literal: true

require 'http'

module Eventure
  module Hccg
    # library for hccg activity api
    class Api
      #   PATH = "https://webopenapi.hccg.gov.tw/v1/Activity?top=#{@top}"

      def initialize(top)
        @top = top
        @path = "https://webopenapi.hccg.gov.tw/v1/Activity?top=#{@top}"
      end

      # return parsed json
      def parsed_json
        Request.new(@top).get(@path).parse
      end

      # use 'top' to get http response
      class Request
        def initialize(top)
          @top = top
        end

        def get(url)
          http_response = HTTP.headers('Accept' => 'application/json').get(url)
          raise 'Request Failed' unless http_response.status.success?

          http_response
        end
      end
    end
  end
end
