# frozen_string_literal: true

require 'date'
require_relative '../domain/values/filter'
require_relative '../domain/entities/user'

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

      def search(activities)
        user = Eventure::Entity::User.new(
          user_id: 1, user_date: [Date.parse('2025-10-31'), Date.parse('2025-11-02')],
          user_theme: %w[教育文化 教育], user_region: [], user_saved: [], user_likes: []
        )
        filter = user.to_filter
        # all_activities = activities_repo.all
        select_activities_by_filter(activities, filter)
      end

      def select_activities_by_filter(activities, filter)
        activity_after_filter = activities.select { |activity| filter.match_filter?(activity) }
        tags_for_filter = activity_after_filter
                          .flat_map { |activity| Array(activity.tags).map { |tag| tag.tag.to_s } }.uniq

        [activity_after_filter, tags_for_filter]
      end

      private

      # def build_filter_from(params)
      #   tags_param, regions_param, raw_start_date, raw_end_date =
      #     params.values_at('filter_tag', 'filter_region', 'start_date', 'end_date')

      #   Eventure::Value::Filter.new(
      #     filter_theme: Array(tags_param).map(&:to_s),
      #     filter_region: Array(regions_param).map(&:to_s),
      #     filter_date: parse_date_range(raw_start_date, raw_end_date)
      #   )
      # end

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
