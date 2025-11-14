# frozen_string_literal: true

require 'dry/monads'
require 'dry/monads/do'

module Eventure
  module Services
    # update likes service
    class UpdateLikes
      include Dry::Monads[:result, :do]

      def call(user:, serno:)
        activity = yield find_activity(serno)
        updated_user = toggle_like(user, serno)
        yield save_to_db(activity, updated_user.user_likes.include?(serno))
        Success(updated_user)
      end

      private

      def find_activity(serno)
        activity = Eventure::Repository::Activities.find_serno(serno)
        return Success(activity) if activity

        Failure(:activity_not_found)
      end

      def toggle_like(user, serno)
        current_likes = user.user_likes.dup

        if current_likes.include?(serno)
          current_likes.delete(serno)
        else
          current_likes << serno
        end

        Eventure::Entity::User.new(
          user_id: user.user_id,
          user_date: user.user_date,
          user_theme: user.user_theme,
          user_region: user.user_region,
          user_saved: user.user_saved,
          user_likes: current_likes
        )
      end

      def save_to_db(activity, is_liked)
        if is_liked
          activity.add_likes
        else
          activity.remove_likes
        end

        Eventure::Repository::Activities.update_likes(activity)
        Success(activity)
      rescue StandardError => e
        Failure(:db_error)
      end
    end
  end
end
