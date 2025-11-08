# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require_relative '../presentation/view_objects/activity_list'

module Eventure
  # main app controller
  class App < Roda
    plugin :flash
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :common_logger, $stdout
    plugin :halt

    route do |routing|
      routing.assets
      response['Content-Type'] = 'text/html; charset=utf-8'

      # root route
      routing.root { routing.redirect '/activities' }

      # activities route
      routing.on 'activities' do
        # GET /activities
        routing.is do
          begin
            show_activities(100)
          rescue StandardError => e
            flash[:error] = "Error loading activities: #{e.message}"
            routing.redirect '/'
          end
        end

        # update likes
        routing.post 'like' do
          # check parameters
          serno = routing.params['serno'] || routing.params['serno[]']
          unless serno
            flash[:error] = 'Missing activity ID'
            routing.halt 400, { error: 'Missing activity ID' }.to_json
          end

          response['Content-Type'] = 'application/json'

          begin
            # try to update likes
            update_likes(serno.to_i)
          rescue StandardError => e
            flash[:error] = "Error updating likes: #{e.message}"
            response.status = 500
            { error: 'Internal server error' }.to_json
          end
        end
      end
    end

    # update likes for an activity
    def update_likes(serno)
      # puts temp_user.user_likes
      session[:user_likes] ||= []
      # fetch avtivity from repo
      activity = Eventure::Repository::Activities.find_serno(serno)
      unless activity
        flash[:error] = 'Activity not found'
        halt 404, { error: 'Activity not found' }.to_json
      end
      # toggle like/unlike
      toggle_like(activity, serno.to_i)
      # save updated likes to db
      Eventure::Repository::Activities.update_likes(activity)
      { likes_count: activity.likes_count || 0 }.to_json
    rescue StandardError => e
      flash[:error] = "Database failed to update: #{e.message}"
      halt 500, { error: 'Database update failed' }.to_json
    end

    # show activites page
    def show_activities(top)
      # get activities from service
      # activities = service.search(top, Eventure::Entity::TempUser.new(user_id: 1))
      if activities.nil? || activities.empty?
        flash[:notice] = 'No activities available'
        return
      end

      liked = Array(session[:user_likes]).map(&:to_i)
      @filtered_activities = activities
      @tags = activities.flat_map { |activity| extract_tags(activity) }.uniq
      view 'home', locals: view_locals.merge(liked_sernos: liked)
    end

    def extract_tags(activity)
      Array(activity.tags).map { |tag| tag.tag.to_s }
    end

    def view_locals
      {
        cards: Views::ActivityList.new(activities),
        total_pages: 1,
        current_page: 1
      }
    end

    def activities
      @activities ||= Eventure::Repository::Activities.all
    end

    def service
      @service ||= Eventure::Services::ActivityService.new
    end

    private

    def toggle_like(activity, serno)
      user_likes = session[:user_likes]
      if user_likes.include?(serno)
        activity.remove_likes
        user_likes.delete(serno)
      else
        activity.add_likes
        user_likes << serno
      end
    end
  end
end
