# frozen_string_literal: true

require_relative '../../../domain/entities/activity'
require_relative '../../../domain/entities/tag'
require_relative '../../../domain/entities/relatedata'
require_relative 'activities'
require_relative 'tags'
require_relative 'relatedata'

module Eventure
  module Repository
    # mapping between entity and repository
    module For
      ENTITY_REPOSITORY = {
        Eventure::Entity::Activity => Activities,
        Eventure::Entity::Tag => Tags,
        Eventure::Entity::RelateData => Relatedata
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end
