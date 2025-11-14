# app/services/filter_activities.rb

module Eventure
  module Services
    class FilterActivities
      def call(activities:, filters:)
        filtered = activities.dup

        # 1) Tag filtering
        if filters[:tag] && !filters[:tag].empty?
          tag_set = Array(filters[:tag]).map(&:to_s)
          filtered = filtered.select do |a|
            Array(a.tags).map { |t| t.respond_to?(:tag) ? t.tag.to_s : t.to_s }.intersect?(tag_set)
          end
        end

        # 2) City filtering
        if filters[:city] && !filters[:city].empty?
          city = filters[:city].to_s
          filtered = filtered.select { |a| a.city.to_s == city }

          # 3) District filtering (if not 全區)
          dists = Array(filters[:districts]).map(&:to_s)
          filtered = filtered.select { |a| dists.include?(a.district.to_s) } unless dists.empty? || dists.include?('全區')
        end

        # Return simple Hash response
        { success: true, activities: filtered }
      rescue StandardError => e
        { success: false, error: e.message }
      end
    end
  end
end
