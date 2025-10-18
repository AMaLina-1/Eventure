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
            publish_unit:,
            subject:,
            details:,
            subject_class:, service_class:,
            voice:,
            host:, join:,
            start_time:, end_time:,
            place:
          )
        end

        def publish_unit
          @data['pubunitname']
        end

        def subject
          @data['subject']
        end

        def details
          @data['detailcontent']
        end

        def subject_class
          @data['subjectclass'].split(',').map { |item| item.split(']')[1] }
        end

        def service_class
          @data['serviceclass'].split(',').map { |item| item.split(']')[1] }
        end

        def voice
          @data['voice']
        end

        def host
          @data['hostunit']
        end

        def join
          @data['joinunit']
        end

        def start_time
          DateTime.strptime(@data['activitysdate'], '%Y%m%d%H%M')
        end

        def end_time
          DateTime.strptime(@data['activityedate'], '%Y%m%d%H%M')
        end

        def place
          @data['activityplace']
        end
      end
    end
  end
end
