# frozen_string_literal: true

require 'json'
require 'yaml'
require 'fileutils'

module Eventure
  # 負責把 JSON 轉成只含指定欄位的 YAML
  class JsonToYaml
    def initialize(fields: nil, out_path: nil)
      @fields = fields
      @out_path = out_path
    end

    def write_selected(json_str, yaml_path, fields)
      @fields = fields if fields
      @out_path = yaml_path if yaml_path
      write_pruned_from_json(json_str)
    end

    def write_pruned_from_json(json_str)
      data = JSON.parse(json_str)
      pruned = Array(data).map { |row| prune_row(row) }
      FileUtils.mkdir_p(File.dirname(@out_path))
      File.write(@out_path, pruned.to_yaml)
    end

    private

    def prune_row(row)
      @fields.each_with_object({}) do |field, acc|
        acc[field] = row[field] if row.key?(field)
      end
    end
  end
end
