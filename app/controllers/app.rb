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
        routing.is do
          routing.get do
            view 'home', locals: view_locals
          end
        end
      end
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
