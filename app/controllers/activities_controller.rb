# frozen_string_literal: true

module Eventure
  module Services
    # service for fetching and processing activities
    class ActivityService
      def initialize
        @mapper = Eventure::Hccg::ActivityMapper.new
      end

      def fetch_activities(limit = 100)
        @mapper.find(limit).map(&:to_entity)
      end
    end
  end
end
