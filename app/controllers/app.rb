# frozen_string_literal: true

require 'roda'
require 'slim'

module Eventure
  # main app controller
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stdout
    plugin :halt
    plugin :sessions,
           secret: 'a_very_long_random_secret_key_at_least_64_characters_long_for_security_123456', # 必填，用來加密 session
           cookie_only: true

    route do |routing|
      routing.assets
      response['Content-Type'] = 'text/html; charset=utf-8'

      routing.root do
        routing.redirect '/activities'
      end

      routing.on 'activities' do
        # GET /activities
        routing.is { show_activities(100) }

        routing.post 'like' do
          serno = routing.params['serno'] || routing.params['serno[]']
          update_likes(serno.to_i)
        end
      end
    end

    def update_likes(serno)
      # puts temp_user.user_likes
      session[:user_likes] ||= []
      activity = Eventure::Repository::Activities.find_serno(serno)
      toggle_like(activity, serno.to_i)

      Eventure::Repository::Activities.update_likes(activity)

      response['Content-Type'] = 'application/json'
      { likes_count: activity.likes_count }.to_json
      # { likes_count: new_count }.to_json
    end

    def show_activities(top)
      # service.save_activities(top)
      # @activities = service.search(service.save_activities(top))
      activities = service.search(top, temp_user)
      @activities = activities
      @tags = activities.flat_map { |activity| extract_tags(activity) }.uniq
      view 'home', locals: view_locals
    end

    def extract_tags(activity)
      Array(activity.tags).map { |tag| tag.tag.to_s }
    end

    def view_locals
      {
        cards: activities,
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

    def temp_user
      Eventure::Entity::TempUser.new(
        user_id: 1,
        user_date: [Date.parse('2025-10-31'), Date.parse('2025-11-02')],
        user_theme: %w[教育文化 教育],
        user_region: [], user_saved: [], user_likes: []
      )
    end

    private

    def toggle_like(activity, serno)
      if session[:user_likes].include?(serno)
        activity.remove_likes
        session[:user_likes].delete(serno)
      else
        activity.add_likes
        session[:user_likes] << serno
      end
    end
  end
end
