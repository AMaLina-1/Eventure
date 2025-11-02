# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Entity
    # User entity
    class TempUser
      attr_reader :user_id, :user_date, :user_theme, :user_region, :user_saved, :user_likes

      def initialize(user_id:, user_date: [], user_theme: [], user_region: [], user_saved: [], user_likes: [])
        @user_id = user_id
        @user_date = user_date
        @user_theme = user_theme
        @user_region = user_region
        @user_saved = user_saved
        @user_likes = user_likes
      end

      def update_start_date(date)
        @user_date[0] = date
      end

      def update_end_date(date)
        @user_date[1] = date
      end

      def add_theme(theme)
        return self if @user_theme.include?(theme)

        @user_theme += [theme]
      end

      def remove_theme(theme)
        new(user_theme: @user_theme.reject { |reject_theme| reject_theme == theme })
      end

      def add_region(region)
        return self if @user_region.include?(region)

        new(user_region: @user_region + [region])
      end

      def remove_region(region)
        new(user_region: @user_region.reject { |reject_region| reject_region == region })
      end

      def add_saved(serno)
        return self if @user_saved.include?(serno)

        new(user_saved: @user_saved + [serno])
      end

      def remove_saved(serno)
        new(user_saved: @user_saved.reject { |saved_id| saved_id == serno })
      end

      def add_user_likes(serno)
        return self if @user_likes.include?(serno)

        @user_likes << serno
      end

      def remove_user_likes(serno)
        @user_likes.delete(serno)
      end

      def to_filter
        Value::Filter.new(
          filter_date: @user_date,
          filter_theme: @user_theme,
          filter_region: @user_region
        )
      end

      def to_saved
        Value::Saved.new(saved: @user_saved.map(&:to_s))
      end

      private

      def new(attributes)
        self.class.new(to_h.merge(attributes))
      end
    end
  end
end
