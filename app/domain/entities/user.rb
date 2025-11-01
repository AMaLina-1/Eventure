# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Entity
    # User entity
    class User < Dry::Struct
      include Dry.Types()

      attribute :user_id,      Strict::String
      attribute :user_date,    Strict::Date
      attribute :user_theme,   Strict::String.optional
      attribute :user_region,  Strict::String.optional
      attribute :user_saved,   Strict::Array.default([].freeze)
      attribute :user_likes,   Strict::Array.default([].freeze)

      def update_start_date(date)
        new(user_date: date)
      end

      def update_end_date(date)
        new(user_date: date)
      end

      def add_theme(theme)
        new(user_theme: theme)
      end

      def remove_theme
        new(user_theme: nil)
      end

      def add_region(region)
        new(user_region: region)
      end

      def remove_region
        new(user_region: nil)
      end

      def add_saved(serno)
        return self if user_saved.include?(serno)

        new(user_saved: user_saved + [serno])
      end

      def remove_saved(serno)
        new(user_saved: user_saved.reject { |saved_id| saved_id == serno })
      end

      def add_user_likes(serno)
        return self if user_likes.include?(serno)

        new(user_likes: user_likes + [serno])
      end

      def remove_user_likes(serno)
        new(user_likes: user_likes.reject { |liked_id| liked_id == serno })
      end

      def to_filter
        Value::Filter.new(
          filter_date: user_date,
          filter_theme: user_theme,
          filter_region: user_region
        )
      end

      def to_saved
        Value::Saved.new(saved: !user_saved.empty?)
      end

      private

      def new(attributes)
        self.class.new(to_h.merge(attributes))
      end
    end
  end
end
