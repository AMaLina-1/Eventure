# frozen_string_literal: true

require 'fileutils'
require 'json'
require_relative 'http_request'
require_relative 'json_to_yaml'
require_relative 'activity'

module Eventure
  # Orchestrates fetching HCCG activity JSON, writing pruned YAML fixtures,
  # and returning rows (optionally wrapped as domain objects).
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

    def initialize(writer: JsonToYaml.new, out_path: File.expand_path('../../spec/fixtures/results.yml', __dir__), client: HttpClient.new)
      @writer = writer
      @out_path = out_path
      @client = client
    end

    def run(top: 100, out_path: nil, object_class: nil)
      json_str = fetch_json(top)

      # allow per-call override of out_path while keeping instance state
      @out_path = out_path if out_path

      write_json_to_yaml(json_str)
      parse_rows(json_str, object_class)
    end

    private

    def write_json_to_yaml(json_str)
      FileUtils.mkdir_p(File.dirname(@out_path))
      @writer.write_selected(json_str, @out_path, FIELDS)
    end

    def parse_rows(json_str, object_class)
      data = JSON.parse(json_str)
      Array(data).map { |row| object_class ? object_class.new(row) : row }
    end

    def fetch_json(top)
      @client.get_hccg_activity(top: top).to_s
    end
  end
end

# if $PROGRAM_NAME == __FILE__
#   exporter = Eventure::ActivityExport.new
#   exporter.run(top: 100)
# end
