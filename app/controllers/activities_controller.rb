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

      def save_activities(top)
        entities = fetch_activities(top)
        Repository::For.entity(entities.first).create(entities)
      end
    end
  end
end
