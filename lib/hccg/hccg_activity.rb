# frozen_string_literal: true

require 'fileutils'
require 'json'
require_relative 'http_request'
require_relative 'json_to_yaml'
require_relative 'activity'

module Eventure
  # 負責把 API → YAML 的整段流程串起來
  class ActivityExport
    # 11 個欄位白名單
    FIELDS = %w[
      pubunitname
      subject
      detailcontent
      subjectclass
      serviceclass
      voice
      hostunit
      joinunit
      activitysdate
      activityedate
      activityplace
    ].freeze

    # output
    def run(top: 100, out_path: File.expand_path('../../spec/fixtures/results.yml', __dir__), object_class: Eventure::Activity)
      client = HttpClient.new
      writer = JsonToYaml.new
      res = client.get_hccg_activity(top: top)
      FileUtils.mkdir_p(File.dirname(out_path)) unless Dir.exist?(File.dirname(out_path))
      writer.write_selected(res.to_s, out_path, FIELDS)
      # 解析回傳 JSON，產生物件陣列或回傳 Hash 陣列
      data = JSON.parse(res.to_s)
      Array(data).map do |row|
        object_class ? object_class.new(row) : row
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  exporter = Eventure::ActivityExport.new
  exporter.run(top: 100)
end
