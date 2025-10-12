# frozen_string_literal: true

require 'fileutils'
require 'json'
require_relative 'http_request'
require_relative 'json_to_yaml'

module Eventure
  # 負責把 API → YAML 的整段流程串起來
  class ActivityExporter
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
    def run(top: 100, out_path: File.expand_path('../../spec/fixtures/result.yml', __dir__), object_class: nil)
      client = HttpClient.new
      writer = JsonToYaml.new
      res = client.get_hccg_activity(top: top)
      FileUtils.mkdir_p(File.dirname(out_path)) unless Dir.exist?(File.dirname(out_path))
      writer.write_selected(res.to_s, out_path, FIELDS)
      # 解析回傳 JSON，產生物件陣列或回傳 Hash 陣列
      build_objects(res.to_s, object_class: object_class)
    end

    private

    def build_objects(json_str, object_class: nil)
      data = JSON.parse(json_str)
      Array(data).map do |row|
        h = {}
        FIELDS.each { |k| h[k.to_sym] = row[k] if row.key?(k) }
        object_class ? object_class.new(h) : h
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  exporter = Eventure::ActivityExporter.new
  exporter.run(top: 100)
end
