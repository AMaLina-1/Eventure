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

    route do |routing|
      routing.assets
      response['Content-Type'] = 'text/html; charset=utf-8'

      routing.root do
        routing.redirect '/activities'
      end

      routing.on 'activities' do
        # GET /activities
        routing.is do
          routing.get { show_activities(100) }
        end

        routing.post 'like' do
          serno = routing.params['serno'] || routing.params['serno[]']
          routing.halt 400, 'Missing serno' unless serno

          begin
            # new_count = Eventure::Repository::Activities.add_user_likes(serno)
            new_count = Eventure::Entity::Activity.add_likes(serno)
            response['Content-Type'] = 'application/json'
            { likes_count: new_count }.to_json
          rescue Sequel::NoMatchingRow
            routing.halt 404, 'Activity not found'
          end
        end
      end
    end

    def show_activities(top)
      # service.save_activities(top)
      @activities, @tags = service.search(service.save_activities(top))
      view 'home', locals: view_locals
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
  end
end
