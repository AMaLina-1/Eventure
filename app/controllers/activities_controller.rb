# frozen_string_literal: true

require 'date'
require_relative '../domain/value/filter'

module Eventure
  module Services
    # Service for activities
    class ActivityService
      def initialize
        @mapper = Eventure::Hccg::ActivityMapper.new
      end

      def fetch_activities(limit = 100)
        @mapper.find(limit).map(&:to_entity)
      end

      def save_activities(top)
        entities = fetch_activities(top)
        Repository::For.entity(entities.first).create(entities)
      end

      def search(params,
                 activities_repo: Eventure::Repository::Activities,
                 tags_repo: (Eventure::Repository::Tags if defined?(Eventure::Repository::Tags)))
        filter         = build_filter_from(params)
        all_activities = activities_repo.all

        {
          activities: all_activities.select { |activity| filter.match_filter?(activity) },
          tags: tags_repo.all.map(&:tag)
        }
      end

      private

      def build_filter_from(params)
        tags_param, regions_param, raw_start_date, raw_end_date =
          params.values_at('filter_tag', 'filter_region', 'start_date', 'end_date')

        Eventure::Value::Filter.new(
          filter_theme: Array(tags_param).map(&:to_s),
          filter_region: Array(regions_param).map(&:to_s),
          filter_date: parse_date_range(raw_start_date, raw_end_date)
        )
      end

      # :reek:UtilityFunction
      def parse_date_range(start_raw, end_raw)
        parts = [start_raw, end_raw].map { |date| date.to_s.strip }
        return [] if parts.any?(&:empty?) # 只要有一邊沒填 → 不啟用日期篩選

        [Date.strptime(parts[0], '%Y-%m-%d'),
         Date.strptime(parts[1], '%Y-%m-%d')] # 兩邊都有 → 轉成 Date[]
      rescue ArgumentError
        [] # 格式錯誤也視為沒選
      end
    end
  end
end
