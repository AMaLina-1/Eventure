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

      routing.on 'project' do
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
            project = Hccg::Repository::For [Hccg::Entity::Project].find_id(category: category, id: id)
            members = Hccg::Repository::For [Hccg::Entity::Member].find_project_id(category: category, id: id)

            project ||= OpenStruct.new(
              subject: '新竹市「114年度勞動三法宣導會」，自即日起開放報名!',
              detail: 'something about the project',
              subject_class: [],
              service_class: [],
              place: '',
              start_time: '',
              end_time: '',
            )

            members ||=[
              OpenStruct.new(name: ''),
              OpenStruct.new(name: '')
            ]

            view 'project', locals: { project: project, members: members }
          end
        end
      end 
    end
  end 
end