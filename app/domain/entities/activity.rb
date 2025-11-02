# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'
require 'date'
require_relative 'tag'
require_relative 'relatedata'
require_relative '../values/location'

module Eventure
  module Entity
    # Domain Entity for an activity
    class Activity < Dry::Struct
      include Dry.Types

      attribute :serno,        Strict::Integer
      attribute :name,         Strict::String
      attribute :detail,       Strict::String
      attribute :start_time,   Strict::DateTime
      attribute :end_time,     Strict::DateTime
      attribute :location,     Eventure::Value::Location
      attribute :voice,        Strict::String
      attribute :organizer,    Strict::String
      attribute :tag_ids,      Strict::Array.of(Integer).default([].freeze)
      attribute :tags,         Strict::Array.of(Tag).default([].freeze)
      attribute :relate_data,  Strict::Array.of(RelateData).default([].freeze)
      attribute? :likes_count, Strict::Integer

      def to_entity
        self
      end

      # def relate_data
      #   Eventure::Entity::Activity.relate_data
      # end

      def tag_id
        tag_ids
      end

      def tag
        tags.map(&:tag)
      end

      def relate_url
        relate_data.map(&:relate_url)
      end

      def relate_title
        relate_data.map(&:relate_title)
      end

      def status
        now = DateTime.now
        check_past(now, 3) if end_time < now
        check_future(now, 7) if now < start_time
        'Ongoing'

        # Archived:  end_time < now - 3
        # Expired:   now - 3 <= end_time && end_time <= now
        # Ongoing:   start_time <= now && now < end_time
        # Upcoming:  now < start_time && start_time <= now + 7
        # Scheduled: now + 7 < start_time
      end

      def duration
        diff = ((end_time - start_time) * 24 * 60).to_i
        day, remain = diff.divmod(24 * 60)
        hour, minute = remain.divmod(60)
        "#{day} days #{hour} hours #{minute} minutes"
      end

      def city
        location.city
      end

      def district
        location.district
      end

      def region
        location.city
      end

      def self.add_likes(serno)
        raise ArgumentError, 'serno required' if serno.nil? || serno.to_s.empty?

        Eventure::App.db.transaction do
          db_activity = Database::ActivityOrm.first(serno: serno)
          raise Sequel::NoMatchingRow, 'activity not found' unless db_activity

          db_activity.update(likes_count: db_activity.likes_count.to_i + 1)
          db_activity.likes_count.to_i
        end
      end

      def remove_likes(serno)
        db_activity = Database::ActivityOrm.where(serno: serno).update { likes_count - 1 }
        # raise Sequel::NoMatchingRow, 'activity not found' unless db_activity

        db_activity.update(likes_count: db_activity.likes_count.to_i - 1)
        db_activity.likes_count.to_i
      end

      # private

      def check_past(now, offset)
        end_time < now - offset ? 'Archived' : 'Expired'
      end

      def check_future(now, offset)
        now + offset < start_time ? 'Scheduled' : 'Upcoming'
      end
    end
  end
end

# start_time = DateTime.parse("2025-11-01T19:00:00")
# end_time = DateTime.parse("2025-11-03T7:10:00")
