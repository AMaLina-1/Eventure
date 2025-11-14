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

      # likes page (shows user's liked activities)
      routing.get 'like' do
        liked_sernos = Array(session[:user_likes]).map(&:to_i)
        liked_activities = liked_sernos.map { |s| Eventure::Repository::Activities.find_serno(s) }.compact

        # render like view with the same card component data shape
        view 'like',
             locals: view_locals.merge(cards: Views::ActivityList.new(liked_activities), liked_sernos: liked_sernos)
      end

      # activities route
      routing.on 'activities' do
        # GET /activities
        routing.is do
          if routing.params['filter_tag'] || routing.params['filter_city'] || routing.params['filter_district']
            session[:filters] ||= {}
            session[:filters][:tag]       =
              Array(routing.params['filter_tag'] || routing.params['filter_tag[]']).map(&:to_s).reject(&:empty?)
            session[:filters][:city]      = routing.params['filter_city']&.to_s
            session[:filters][:districts] =
              Array(routing.params['filter_district'] || routing.params['filter_district[]']).map(&:to_s).reject(&:empty?)
          else
            session[:filters] = {}
          end

          show_activities(100)
          # rescue StandardError => e
          #   flash[:error] = "Error loading activities: #{e.message}"
          #   routing.redirect '/'
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
    def show_activities(_top)
      # get activities from service
      # activities = service.search(top, Eventure::Entity::TempUser.new(user_id: 1))
      all = activities
      if all.nil? || all.empty?
        flash[:notice] = 'No activities available'
        return
      end

      # apply filters stored in session
      filters = session[:filters] || {}
      filtered = all.dup

      if filters[:tag] && !filters[:tag].empty?
        tag_set = Array(filters[:tag]).map(&:to_s)
        filtered = filtered.select do |a|
          (Array(a.tags).map { |t| t.respond_to?(:tag) ? t.tag.to_s : t.to_s } & tag_set).any?
        end
      end

      if filters[:city] && !filters[:city].empty?
        city = filters[:city].to_s

        filtered = filtered.select { |a| a.city.to_s == city }

        dists = Array(filters[:districts]).map(&:to_s)
        filtered = filtered.select { |a| dists.include?(a.district.to_s) } if dists.any? && !dists.include?('全區')
      end

      liked = Array(session[:user_likes]).map(&:to_i)
      @filtered_activities = filtered
      @tags = all.flat_map { |a| extract_tags(a) }.uniq
      @cities = all.map { |a| a.city.to_s }.compact.uniq
      @current_filters = filters

      grouped = all.group_by { |a| a.city.to_s }
      @districts_by_city = grouped.transform_values do |arr|
        dists = arr.map { |a| a.district.to_s }.compact.uniq
        ['全區'] + dists
      end

      view 'home',
           locals: view_locals.merge(liked_sernos: liked, cities: @cities,
                                     tags: @tags, current_filters: @current_filters, districts: @districts_by_city)
    end

    def extract_tags(activity)
      Array(activity.tags).map { |tag| tag.tag.to_s }
    end

    def view_locals
      {
        cards: Views::ActivityList.new(@filtered_activities || activities),
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
