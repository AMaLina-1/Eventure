# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'
require_relative '../../presentation/view_objects/activity_list'
require_relative '../services/filtered_activities'
# require_relative '../services/update_likes'
require_relative '../services/update_like_counts'

module Eventure
  class App < Roda
    plugin :flash
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :common_logger, $stdout
    plugin :halt

    route do |routing|
      routing.assets
      response['Content-Type'] = 'text/html; charset=utf-8'

      routing.root { routing.redirect '/activities' }

      # ================== Likes page ==================
      routing.get 'like' do
        liked_sernos = Array(session[:user_likes]).map(&:to_i)
        liked_activities = liked_sernos.map { |serno| Eventure::Repository::Activities.find_serno(serno) }.compact

        view 'like',
             locals: view_locals.merge(
               cards: Views::ActivityList.new(liked_activities),
               liked_sernos: liked_sernos
             )
      end

      # ================== Activities ==================
      routing.on 'activities' do
        routing.is do
          session[:filters] = extract_filters(routing)
          result = Eventure::Service::FilteredActivities.new.call(filters: session[:filters])

          if result.failure?
            flash[:error] = result.failure
          else
            result = result.value!
            @filtered_activities = result[:filtered_activities]
            show_activities(result[:all_activities])
          end
        end

        routing.post 'like' do
          response['Content-Type'] = 'application/json'
          serno = routing.params['serno'] || routing.params['serno[]']
          session[:user_likes] ||= []

          result = Service::UpdateLikeCounts.new.call(serno: serno.to_i, user_likes: session[:user_likes])

          if result.failure?
            flash[:error] = result.failure
            # response.status = 500
            # { error: 'Internal server error' }.to_json
          else
            result = result.value!
            session[:user_likes] = result[:user_likes]
            { serno: serno.to_i, likes_count: result[:like_counts] }.to_json
          end
          # routing.halt 400, { error: 'Missing activity ID' }.to_json unless serno

          # response['Content-Type'] = 'application/json'

          # service = Eventure::Services::UpdateLikes.new
          # result = service.call(serno: serno.to_i, session: session)

          # case result
          # when Dry::Monads::Result::Success
          #   { likes_count: result_value![:likes_count] }.to_json
          # when Dry::Monads::Result::Failure
          #   case result.failure
          #   when :activity_not_found
          #     response.status = 404
          #     { error: 'Activity not found' }.to_json
          #   when :db_error
          #     response.statue = 500
          #     { error: 'Database update failed' }.to_json
          #   else
          #     response.status = 500
          #     { error: 'Unknown error' }.to_json
          #   end
          # end
        end
      end
    end

    # ================== Show Activities ==================
    def show_activities(all)
      grouped = all.group_by(&:city)
      districts_by_city = grouped.transform_values do |arr|
        dists = arr.map(&:district).uniq
        ['全區'] + dists
      end

      @tags = all.flat_map { |activity| extract_tags(activity) }.uniq
      @cities = all.map { |activity| activity.city.to_s }.uniq
      @current_filters = session[:filters]
      @districts_by_city = districts_by_city
      view 'home',
           locals: view_locals.merge(
             liked_sernos: Array(session[:user_likes]).map(&:to_i)
             #  cities: all.map { |activity| activity.city.to_s }.uniq,
             #  tags: all.flat_map { |activity| extract_tags(activity) }.uniq,
             #  current_filters: session[:filters],
             #  districts: districts_by_city
           )
    end

    # 把 params 換成乾淨 hash
    def extract_filters(routing)
      {
        tag: Array(routing.params['filter_tag'] || routing.params['filter_tag[]']).map(&:to_s).reject(&:empty?),
        city: routing.params['filter_city']&.to_s,
        districts: Array(routing.params['filter_district'] || routing.params['filter_district[]'])
          .map(&:to_s).reject(&:empty?),
        start_date: routing.params['filter_start_date']&.to_s,
        end_date: routing.params['filter_end_date']&.to_s
      }
    end

    # 把 Tag entity 轉成字串
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
