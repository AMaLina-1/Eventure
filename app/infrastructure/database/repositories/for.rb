# frozen_string_literal: true

require_relative '../../../models/entities/activity'
require_relative '../../../models/entities/tag'
require_relative '../../../models/entities/relatedata'
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
        Eventure::Entity::RelatedData => Relatedata
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