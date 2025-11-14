# frozen_string_literal: true

require 'dry/monads'

module Eventure
  module Services
    class ToggleLike
      include Dry::Monads[:result]

      def call(session:, serno:)
        session[:user_likes] ||= []

        activity = Eventure::Repository::Activities.find_serno(serno)
        return Failure('Activity not found') unless activity

        # toggle like/unlike
        if session[:user_likes].include?(serno)
          activity.remove_likes
          session[:user_likes].delete(serno)
        else
          activity.add_likes
          session[:user_likes] << serno
        end

        # persist to DB
        Eventure::Repository::Activities.update_likes(activity)

        Success(activity.likes_count || 0)
      rescue StandardError => e
        Failure(e.message)
      end
    end
  end
end
