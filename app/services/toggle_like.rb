# app/services/toggle_like.rb

module Eventure
  module Services
    class ToggleLike
      def call(session:, serno:)
        session[:user_likes] ||= []

        activity = Eventure::Repository::Activities.find_serno(serno)
        return { success: false, error: 'Activity not found' } unless activity

        # toggle
        if session[:user_likes].include?(serno)
          activity.remove_likes
          session[:user_likes].delete(serno)
        else
          activity.add_likes
          session[:user_likes] << serno
        end

        # persist like count
        Eventure::Repository::Activities.update_likes(activity)

        { success: true, likes_count: activity.likes_count || 0 }
      rescue StandardError => e
        { success: false, error: e.message }
      end
    end
  end
end
