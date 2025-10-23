# frozen_string_literal: true

module Eventure
  module Hccg
    # data mapper: hccg api response -> Activity entity
    class ActivityMapper
      def initialize(gateway_class = Hccg::Api)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
        @parsed_data = nil
      end

      # transfer parsed json object into ActicityMapper object
      def find(top)
        @parsed_data = @gateway.parsed_json(top)
        build_entity
      end

      def build_entity
        @parsed_data.map { |line| DataMapper.new(line) }
      end

      # Extracts entity elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def to_entity
          Eventure::Entity::Activity.new(
            serno:,
            name:,
            detail:,
            start_time:, end_time:,
            location:,
            voice:,
            organizer:,
            tag_id:, tag:,
            relate_url:, relate_title:
          )
        end

        def serno
          @data['serno']
        end

        def name
          @data['subject']
        end

        def detail
          @data['detailcontent']
        end

        def start_time
          DateTime.strptime(@data['activitysdate'], '%Y%m%d%H%M')
        end

        def end_time
          DateTime.strptime(@data['activityedate'], '%Y%m%d%H%M')
        end

        def location
          @data['activityplace']
        end

        def voice
          @data['voice']
        end

        def organizer
          @data['hostunit']
        end

        def tag_id
          @data['subjectid'].split(',')
        end

        def tag
          @data['subjectclass'].split(',').map { |item| item.split(']')[1] }
        end

        def relate_url
          @data['resourcedatalist'].map { |resourcedata| resourcedata['relateurl'] }
        end

        def relate_title
          @data['resourcedatalist'].map { |resourcedata| resourcedata['relatename'] }
        end
      end
    end
  end
end
