# frozen_string_literal: true

require 'date'

require_relative '../../../domain/entities/activity'
require_relative '../../../domain/entities/tag'
require_relative '../../../domain/entities/relatedata'

module Eventure
  module Hccg
    # data mapper: hccg api response -> Activity entity
    class ActivityMapper
      def initialize(gateway_class = Hccg::Api)
        @gateway_class = gateway_class
        @gateway = @gateway_class.new
        @parsed_data = nil
      end

      def find(top)
        @parsed_data = @gateway.parsed_json(top)
        build_entity
      end

      def build_entity
        @parsed_data.map { |line| DataMapper.new(line).to_entity }
      end

      def self.to_attr_hash(entity)
        {
          serno: entity.serno,
          name: entity.name,
          detail: entity.detail,
          start_time: entity.start_time.to_time.utc,
          end_time: entity.end_time.to_time.utc,
          location: entity.location,
          voice: entity.voice,
          organizer: entity.organizer
        }
      end

      # Extracts entity elements from raw data
      class DataMapper
        def initialize(data)
          @data = data
        end

        def to_entity
          Eventure::Entity::Activity.new(
            serno:, name:,
            detail:,
            start_time:, end_time:,
            location:,
            voice:,
            organizer:,
            tag_ids:, tags:,
            relate_data:
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
          tag_texts = @data['subjectclass'].split(',')
          tag_texts.map.with_index do |tag_text, index|
            Eventure::Entity::Tag.new(
              tag_id: tag_ids[index],
              tag: tag_text.split(']')[1]
            )
          end
        end

        def relate_data
          resource_list = @data['resourcedatalist']
          return [] if resource_list.empty?

          resource_list.map do |relate_item|
            self.class.build_relate_data_entity(relate_item)
          end.compact
        end

        def self.build_relate_data_entity(relate_item)
          return unless relate_item

          Eventure::Entity::RelateData.new(
            relatedata_id: nil,
            relate_title: relate_item['relatename'],
            relate_url: relate_item['relateurl']
          )
        end
      end
    end
  end
end
