# frozen_string_literal: true

require 'json'
require 'uri'
require 'http'

module HccgEventure
  # 只負責 HTTP 溝通，不做資料解析（交給 Activity）
  class Api
    def initialize(base_url: API_BASE)
      @base_url = base_url
      @http = HTTP.timeout(connect: TIMEOUT_S, read: TIMEOUT_S)
                  .headers('Accept' => 'application/json', 'User-Agent' => USER_AGENT)
    end

    # 取得活動清單
  # 回傳：Array<HccgEventure::Activity>
    def activities(top: 100, query: nil)
      raise ArgumentError, 'top must be positive' unless top.to_i.positive?

      path   = '/v1/Activity'
      params = { top: top }
      params[:query] = query if query

      json = get_json(path, params)
      Array(json).map { |row| Activity.new(row) }
    end

    private

    def get_json(path, params)
      url = build_url(@base_url, path, params)
      res = @http.get(url)
      unless res.status.success?
        raise HTTPError.new("HCCG API #{res.status}", status: res.status, body: res.to_s)
      end
      JSON.parse(res.to_s)
    end

    def build_url(base, path, params)
      uri = URI.join(base, path)
      unless params.nil? || params.empty?
        q = URI.decode_www_form(String(uri.query)) + params.compact.map { |k, v| [k.to_s, v.to_s] }
        uri.query = URI.encode_www_form(q)
      end
      uri.to_s
    end
  end
end
if $PROGRAM_NAME == __FILE__
  # 讓這支檔案可獨立執行時，自己把依賴載好
  require 'json'
  require_relative 'eventure'   # 這會載入 models/activity、errors、常數等

  api  = HccgEventure::Api.new
  list = api.activities(top: 100)

  puts "Retrieved #{list.length} activities"
  list.each_with_index do |a, i|
    h = a.to_h
    puts "[#{i + 1}] #{h[:subject]} @ #{h[:activityplace]} (#{h[:activitysdate]} ~ #{h[:activityedate]})"
  end
  require 'yaml'
  require 'fileutils'

  fixtures_dir = File.expand_path('../../spec/fixtures', __FILE__)
  FileUtils.mkdir_p(fixtures_dir) unless Dir.exist?(fixtures_dir)
  out_path = File.join(fixtures_dir, 'hccg_activities_api_result.yml')

  yaml_array = list.map { |a| a.to_h.transform_keys(&:to_s) }
  File.write(out_path, YAML.dump(yaml_array))
  puts "Wrote YAML to #{out_path}"
end