# frozen_string_literal: true

require 'fileutils'
require_relative 'http_request'
require_relative 'json_to_yaml'

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
    def run(top: 100, out_path: File.expand_path('../../spec/fixtures/result.yml', __dir__))
      res = HttpRequest.new.get_hccg_activity(top: top)
      FileUtils.mkdir_p(File.dirname(out_path)) unless Dir.exist?(File.dirname(out_path))
      JsonToYaml.new.write_selected(res.to_s, out_path, FIELDS)

      JSON.parse(res.to_s)
    end
  end
end

# if $PROGRAM_NAME == __FILE__
#   Eventure::ActivityExport.run(top: 100)
# end
