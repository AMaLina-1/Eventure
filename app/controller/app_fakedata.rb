# frozen_string_literal: true

require 'roda'
require 'slim'
require 'rack/utils'

module Eventure
  class App < Roda
    CITIES = %w[台北市 新北市 桃園市 台中市 台南市 高雄市 基隆市].freeze
    TAGS = %w[講座 展覽 工作坊 音樂 運動 家庭 兒童].freeze

    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stdout
    plugin :halt
    plugin :hooks # ✅ 讓 before/after hooks 可用

    # ✅ 每個請求都會先跑這裡，讓 layout 永遠拿得到資料
    before do
      @cities = CITIES
      # fake tags for filtering (供 modal 使用)
      @tags = TAGS
    end

    route do |r|
      r.assets
      response['Content-Type'] = 'text/html; charset=utf-8'

      r.root do
        # （可選）接收目前選到的城市，供 layout 高亮或過濾使用
        @current_city = r.params['city']

        # seed fake data for development / UI testing
        all_cards = (1..2000).map do |i|
          {
            name: "活動名稱 #{i}",
            description: "這是第 #{i} 個活動的描述。",
            long_description: "這是第 #{i} 個活動的詳細描述。內容非常豐富，可以包含多段文字、圖片，甚至是嵌入影片等多媒體元素。",
            link: '#',
            id: i,
            city: CITIES.sample,
            tags: TAGS.sample(rand(1..3))
          }
        end

        # 先依城市過濾（如果有）
        filtered = @current_city && @current_city != '' ? all_cards.select { |c| c[:city] == @current_city } : all_cards

        # 再依標籤過濾（如果 URL 有 tag 參數，tag 可以是逗號分隔的多個值）
        if r.params['tag'] && !r.params['tag'].strip.empty?
          wanted = r.params['tag'].split(',').map(&:strip)
          filtered = filtered.select { |c| (c[:tags] & wanted).any? }
        end

        # simple server-side pagination
        page = r.params['page'].to_i
        page = 1 if page < 1
        per_page = 30
        total_pages = (filtered.size.to_f / per_page).ceil
        start_index = (page - 1) * per_page

        @cards        = filtered.slice(start_index, per_page) || []
        @current_page = page
        @total_pages  = total_pages

        view 'home'
      end

      routing.on 'hccg' do
        routing.is do
          routing.post do
            # will edit this later on
            category = routing.params['category']
            id = routing.params['id']
            routing.halt 400, 'Missing params' if category.nil? || id.nil?
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
