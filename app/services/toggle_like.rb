# frozen_string_literal: true

require 'dry/monads'

module Eventure
  module Services
    class ToggleLike # rubocop:disable Style/Documentation
      include Dry::Monads[:result]

      def call(session:, serno:)
        session[:user_likes] ||= []

        activity = find_activity(serno)
        return Failure('Activity not found') if activity.nil?

        toggle_like!(session, activity, serno)
        persist_likes(activity)

        Success(activity.likes_count || 0)
      rescue StandardError => e
        Failure(e.message)
      end

      private

      def find_activity(serno)
        Eventure::Repository::Activities.find_serno(serno)
      end

      def toggle_like!(session, activity, serno)
        if session[:user_likes].include?(serno)
          activity.remove_likes
          session[:user_likes].delete(serno)
        else
          activity.add_likes
          session[:user_likes] << serno
        end
      end

      def persist_likes(activity)
        Eventure::Repository::Activities.update_likes(activity)
      end
    end
  end
end
