# frozen_string_literal: true

require 'json'
require 'yaml'
require 'fileutils'

module Eventure
  # 負責把 JSON 轉成只含指定欄位的 YAML
  class JsonToYaml
    def self.write_selected(json_str, yaml_path, fields)
      data = JSON.parse(json_str)
      pruned = Array(data).map do |row|
        fields.each_with_object({}) { |k, h| h[k] = row[k] if row.key?(k) }
      end
      FileUtils.mkdir_p(File.dirname(yaml_path))
      File.write(yaml_path, pruned.to_yaml)
      puts "Wrote #{yaml_path} (#{pruned.size} records)"
    end
  end
end
