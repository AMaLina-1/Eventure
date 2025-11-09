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
        handle_activities_routes(routing)
      end
    end

    private

    def handle_activities_routes(routing)
      # GET /activities
      routing.is do
        show_activities
      rescue StandardError => e # :reek:UncommunicativeVariableName
        flash[:error] = "Error loading activities: #{e.message}"
        routing.redirect '/'
      end

      # update likes
      routing.post 'like' do
        handle_like_request(routing)
      end
    end

    def handle_like_request(routing)
      serno = routing.params['serno'] || routing.params['serno[]']
      unless serno
        flash[:error] = 'Missing activity ID'
        routing.halt 400, { error: 'Missing activity ID' }.to_json
      end
      response['Content-Type'] = 'application/json'
      # try to update likes
      update_likes(serno.to_i)
    rescue StandardError => e # :reek:UncommunicativeVariableName
      handle_like_error(e)
    end

    def handle_like_error(exception)
      flash[:error] = "Error updating likes: #{exception.message}"
      response.status = 500
      { error: 'Internal server error' }.to_json
    end

    # update likes for an activity
    def update_likes(serno)
      session[:user_likes] ||= []
      # fetch activity from repo
      activity = fetch_activity(serno)
      # toggle like/unlike
      user_like_manager.toggle_like(activity, serno)
      # save updated likes to db
      Repository::Activities.update_likes(activity)
      { likes_count: activity.likes_count || 0 }.to_json
    rescue StandardError => e # :reek:UncommunicativeVariableName
      handle_update_error(e)
    end

    def fetch_activity(serno)
      activity = Eventure::Repository::Activities.find_serno(serno)
      return activity if activity

      flash[:error] = 'Activity not found'
      halt 404, { error: 'Activity not found' }.to_json
    end

    def handle_update_error(exception)
      flash[:error] = "Database failed to update: #{exception.message}"
      halt 500, { error: 'Database update failed' }.to_json
    end

    # show activities page
    def show_activities
      unless activities&.any?
        flash[:notice] = 'No activities available'
        return nil
      end
      liked = Array(session[:user_likes]).map(&:to_i)
      prepare_activity_view(liked)
    end

    def prepare_activity_view(liked_sernos)
      @filtered_activities = activities
      @tags = activities.flat_map { |activity| extract_tags(activity) }.uniq
      view 'home', locals: view_locals.merge(liked_sernos: liked_sernos)
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

    def user_like_manager
      @user_like_manager ||= UserLikeManager.new(session)
    end
  end
end
