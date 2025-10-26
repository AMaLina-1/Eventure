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
          routing.get { show_activities(100) }
        end
      end
    end

    def show_activities(top)
      service.save_activities(top)

      # prepare tags for the view
      @tags = if defined?(Eventure::Repository::Tags) && Eventure::Repository::Tags.respond_to?(:all)
                Eventure::Repository::Tags.all.map(&:tag)
              else
                Eventure::Repository::Activities.all.flat_map { |a| Array(a.tags).map(&:tag) }.uniq
              end

      # read selected tags from params (name is filter_tag[] in the form)
      selected = Array(request.params['filter_tag'] || []).map(&:to_s)

      all_activities = Eventure::Repository::Activities.all
      @activities = if selected.empty?
                      all_activities
                    else
                      all_activities.select do |a|
                        Array(a.tags).map { |t| t.tag.to_s }.intersect?(selected)
                      end
                    end

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
