# frozen_string_literal: true

module Eventure
  # Manages user likes for activities
  class UserLikeManager
    def initialize(session)
      @session = session
    end

    def toggle_like(activity, serno)
      if user_likes.include?(serno)
        unlike_activity(activity, serno)
      else
        like_activity(activity, serno)
      end
    end

    private

    def user_likes
      @session[:user_likes] ||= []
    end

    def like_activity(activity, serno)
      activity.add_likes
      user_likes << serno
    end

    def unlike_activity(activity, serno)
      activity.remove_likes
      user_likes.delete(serno)
    end
  end
end
