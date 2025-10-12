# frozen_string_literal: true

require 'json'
require 'yaml'
require 'fileutils'

# process hccg activity data
module Eventure
  # 負責把 JSON 轉成只含指定欄位的 YAML
  class JsonToYaml
    def write_selected(json_str, yaml_path, fields)
      data = JSON.parse(json_str)
      pruned = Array(data).map { |row| self.class.prune_row(row, fields) }

      FileUtils.mkdir_p(File.dirname(yaml_path))
      File.write(yaml_path, pruned.to_yaml)
    end
  end

  def self.prune_row(row, fields)
    fields.each_with_object({}) do |field, hash|
      hash[field] = row[field] if row.key?(field)
    end
  end
end
