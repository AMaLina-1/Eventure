# frozen_string_literal: true 

require 'roda'
require 'slim'

module Eventure 
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
            mapper = Eventure::Hccg::ActivityMapper.new
            activities = mapper.find(10).map(&:to_entity)
          
            view 'home', locals: { cards: activities, total_pages: 1, current_page: 1 }
          end
        end
      end 
    end
  end 
end