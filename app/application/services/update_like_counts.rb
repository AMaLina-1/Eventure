# frozen_string_literal: true

require 'dry/transaction'

module Eventure
  module Service
    # Transaction to update like counts (input: serno, user_likes)
    class UpdateLikeCounts
      include Dry::Transaction

      step :fetch_activity
      step :update_like_session
      step :save_like_db

      private

      def fetch_activity(input)
        input[:activity] = Eventure::Repository::Activities.find_serno(input[:serno])
        if input[:activity]
          Success(input)
        else
          Failure('Activity not found')
        end
      end

      def update_like_session(input)
        if input[:user_likes].include?(input[:serno])
          input[:activity].remove_likes
          input[:user_likes].delete(input[:serno])
        else
          input[:activity].add_likes
          input[:user_likes] << input[:serno]
        end
        Success(input)
      rescue StandardError => e
        Failure(e.to_s)
      end

      def save_like_db(input)
        Eventure::Repository::Activities.update_likes(input[:activity])
        Success(user_likes: input[:user_likes], like_counts: input[:activity].likes_count)
      rescue StandardError => e
        Failure("Database failed to update: #{e}")
      end
    end
  end
end
