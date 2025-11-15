# frozen_string_literal: true

require 'dry/monads'

module Eventure
  module Services
    class FilterActivities # rubocop:disable Style/Documentation
      include Dry::Monads[:result]

      def call(activities:, filters:)
        filtered = activities.dup

        filtered = filter_by_tags(filtered, filters)
        filtered = filter_by_city(filtered, filters)
        filtered = filter_by_districts(filtered, filters)
        filtered = filter_by_date(filtered, filters)

        Success(filtered)
      rescue StandardError => e
        Failure(e.message)
      end

      private

      def filter_by_tags(list, filters)
        return list if filters[:tag].nil? || filters[:tag].empty?

        tag_set = filters[:tag].map(&:to_s)

        list.select do |activity|
          tags = Array(activity.tags).map { |ac_tag| ac_tag.respond_to?(:tag) ? ac_tag.tag.to_s : ac_tag.to_s }
          tags.intersect?(tag_set)
        end
      end

      def filter_by_city(list, filters)
        return list if filters[:city].to_s.empty?

        city = filters[:city].to_s
        list.select { |activity| activity.city.to_s == city }
      end

      def filter_by_districts(list, filters)
        dists = Array(filters[:districts]).map(&:to_s)
        return list if dists.empty? || dists.include?('全區')

        list.select { |activity| dists.include?(activity.district.to_s) }
      end

      def filter_by_date(list, filters)
        start_raw = filters[:start_date]
        end_raw   = filters[:end_date]

        return list unless start_raw || end_raw

        start_dt = parse_date(start_raw)
        end_dt   = parse_date(end_raw)

        if start_dt && end_dt
          list.select do |ac_date|
            ad = ac_date.activity_date
            ad&.start_time&.between?(start_dt, end_dt)
          end
        elsif start_dt
          list.select do |ac_date|
            ad = ac_date.activity_date
            ad&.start_time && ad.start_time >= start_dt
          end
        elsif end_dt
          list.select do |ac_date|
            ad = ac_date.activity_date
            ad&.start_time && ad.start_time <= end_dt
          end
        else
          list
        end
      end

      # Helper — safe parse
      def parse_date(raw)
        return nil if raw.nil? || raw.to_s.strip.empty?

        DateTime.parse(raw.to_s)
      rescue StandardError
        nil
      end
    end
  end
end
