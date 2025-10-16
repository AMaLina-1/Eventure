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
        view 'home'
      end 

      routing.on 'hccg' do
        routing.is do 
          routing.post do 
            # will edit this later on 
            category = routing.params['category']
            id = routing.params['id']
            routing.halt 400, "Missing params" if category.nil? || id.nil?
            routing.redirect "hccg/#{category}/#{id}"
          end 
        end 
        routing.on String, String do |category, id|
          routing.get do 
            # will edit this later on 
            api_url = "https://www.hccg.gov.tw/example/#{category}/#{id}"
            response = Net::HTTP.get(api_url)
            card_data = JSON.parse(response)
            view 'hccg_card', locals: { card: card_data }
          end
        end
      end 
    end
  end 
end