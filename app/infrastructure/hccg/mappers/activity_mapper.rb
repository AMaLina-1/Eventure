# frozen_string_literal: true

require 'date'

require_relative '../../../models/entities/activity'
require_relative '../../../models/entities/tag'
require_relative '../../../models/entities/relatedata'

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
        @parsed_data.map { |line| DataMapper.new(line).to_entity }
      end

      # Extracts entity elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def to_entity
          Eventure::Entity::Activity.new(
            serno: serno,
            name: name,
            detail: detail,
            start_time: start_time,
            end_time: end_time,
            location: location,
            voice: voice,
            organizer: organizer,
            tag_ids: tag_ids,
            tags: tags,
            related_data: related_data
          )
        end

        def serno
          Integer(@data['serno'])
        end

        def name
          @data['subject']
        end

        def detail
          @data['detailcontent']
        end

        def start_time
          DateTime.strptime(@data['activitysdate'], '%Y%m%d%H%M').new_offset(0)
        end

        def end_time
          DateTime.strptime(@data['activityedate'], '%Y%m%d%H%M').new_offset(0)
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

        def tag_ids
          @data['subjectid'].split(',').map(&:to_i)
        end

        def tags
          @data['subjectclass'].split(',').map.with_index do |t, i|
            Eventure::Entity::Tag.new(tag_id: tag_ids[i], tag: t.split(']')[1])
          end
        end

        def related_data
          @data['resourcedatalist'].map do |rd|
            Eventure::Entity::RelatedData.new(
              relatedata_id: nil,
              relate_title: rd['relatename'],
              relate_url: rd['relateurl']
            )
          end
        end
      end
    end
  end
end