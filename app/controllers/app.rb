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
          if routing.params['filter_tag'] || routing.params['filter_city']
            session[:filters] = {
              tag: Array(routing.params['filter_tag'] || routing.params['filter_tag[]']).map(&:to_s).reject(&:empty?),
              city: routing.params['filter_city']&.to_s
            }.compact
          else
            session.delete(:filters)
          end

          show_activities(100)
        rescue StandardError => e
          flash[:error] = "Error loading activities: #{e.message}"
          routing.redirect '/'
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

          service = Eventure::Services::UpdateLikes.new
          result = service.call(serno: serno.to_i, session: session)

          case result
          when Dry::Monads::Result::Success
            { likes_count: result_value![:likes_count] }.to_json
          when Dry::Monads::Result::Failure
            case result.failure
            when :activity_not_found
              response.status = 404
              { error: 'Activity not found' }.to_json
            when :db_error
              response.statue = 500
              { error: 'Database update failed' }.to_json
            else
              response.status = 500
              { error: 'Unknown error' }.to_json
            end
          end
        end
      end
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
          Array(a.tags).map { |t| t.tag.to_s }.intersect?(tag_set)
        end
      end

      if filters[:city] && !filters[:city].to_s.empty?
        city = filters[:city].to_s
        filtered = filtered.select do |a|
          # attempt to read city from activity.location if available
          a.respond_to?(:location) && a.location && a.location.city && a.location.city.to_s == city
        end
      end

      liked = Array(session[:user_likes]).map(&:to_i)
      @filtered_activities = filtered
      @tags = all.flat_map { |activity| extract_tags(activity) }.uniq
      @current_filters = filters

      view 'home', locals: view_locals.merge(liked_sernos: liked)
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
  end
end
