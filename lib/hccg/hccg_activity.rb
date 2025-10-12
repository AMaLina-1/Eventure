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
      self_class = self.class
      response_body = self_class.fetch_data(top)
      self_class.write_output(response_body, out_path)
      build_objects(response_body, object_class)
    end

    private

    def build_objects(json_str, object_class)
      data = JSON.parse(json_str)
      Array(data).map do |row|
        object_class ? object_class.new(row) : row
      end
    end

    # Class-level utility functions
    class << self
      def fetch_data(top)
        HttpClient.new.get_hccg_activity(top: top).to_s
      end

      def write_output(json_str, out_path)
        FileUtils.mkdir_p(File.dirname(out_path))
        JsonToYaml.new.write_selected(json_str, out_path, FIELDS)
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  exporter = Eventure::ActivityExport.new
  exporter.run(top: 100)
end
