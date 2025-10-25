# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'
require_relative 'tag'
require_relative 'relatedata'

module Eventure
  module Entity
    # Domain Entity for an activity
    class Activity < Dry::Struct
      include Dry.Types

      attribute :serno,        Integer
      attribute :name,         String
      attribute :detail,       String
      attribute :start_time,   DateTime
      attribute :end_time,     DateTime
      attribute :location,     String
      attribute :voice,        String
      attribute :organizer,    String
      attribute :tag_ids,      Array.of(Integer).default([].freeze)
      attribute :tags,         Array.of(Tag).default([].freeze)
      attribute :relate_data, Array.of(RelateData).default([].freeze)

      def to_entity
        self
      end

      # def relate_data
      #   Eventure::Entity::Activity.relate_data
      # end

      def tag_id
        tag_ids
      end

      def tag
        tags.map(&:tag)
      end

      def relate_url
        relate_data.map(&:relate_url)
      end

      def relate_title
        relate_data.map(&:relate_title)
      end
    end
  end
end
