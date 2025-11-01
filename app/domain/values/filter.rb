# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Value
    # Filter value object
    class Filter < Dry::Struct
      include Dry.Types()

      attribute :filter_date, Strict::Array.of(Date).default([].freeze)
      attribute :filter_theme, Strict::Array.of(String).default([].freeze)
      attribute :filter_region, Strict::Array.of(String).default([].freeze)

      def match_filter?(activity)
        start_time = activity.start_time
        end_time   = activity.end_time || start_time
        date_ok?(start_time, end_time) && theme_ok?(activity) && region_ok?(activity)
      end

      def ==(other)
        other.instance_of?(self.class) && to_h == other.to_h
      end

      private

      def date_ok?(start_time, end_time)
        start_date, end_date = filter_date
        return true unless start_date && end_date

        start_time && end_time &&
          end_time   >= start_date.to_datetime &&
          start_time <= end_date.to_datetime
      end

      def theme_ok?(activity)
        return true if filter_theme.empty?

        activity_tag_values = Array(activity.tags).map { |tag_obj| tag_obj.tag.to_s }
        activity_tag_values.intersect?(filter_theme)
      end

      def region_ok?(activity)
        return true if filter_region.empty?

        city_value     = activity.city.to_s
        district_value = activity.district.to_s

        filter_region.include?(city_value) || filter_region.include?(district_value)
      end
    end
  end
end
