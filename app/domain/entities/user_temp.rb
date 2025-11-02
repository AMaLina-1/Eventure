# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Entity
    # User entity
    class TempUser
      attr_reader :user_id, :user_date, :user_theme, :user_region, :user_saved, :user_likes

      def initialize(user_id:)
        @user_id = user_id
        @user_date = []
        @user_theme = []
        @user_region = []
        @user_saved = []
        @user_likes = []
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
