# frozen_string_literal: true

require 'dry/monads'

module Eventure
  module Services
    class FilterActivities
      include Dry::Monads[:result]

      def call(activities:, filters:)
        filtered = activities.dup

        # 1) Tag filtering
        if filters[:tag] && !filters[:tag].empty?
          tag_set = Array(filters[:tag]).map(&:to_s)

          filtered = filtered.select do |a|
            tags = Array(a.tags).map { |t| t.respond_to?(:tag) ? t.tag.to_s : t.to_s }
            !(tags & tag_set).empty?
          end
        end

        # 2) City filtering
        if filters[:city] && !filters[:city].empty?
          city = filters[:city].to_s
          filtered = filtered.select { |a| a.city.to_s == city }

          # 3) District filtering
          dists = Array(filters[:districts]).map(&:to_s)
          filtered = filtered.select { |a| dists.include?(a.district.to_s) } unless dists.empty? || dists.include?('全區')
        end

        Success(filtered)
      rescue StandardError => e
        Failure(e.message)
      end
    end
  end
end
