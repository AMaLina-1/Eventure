# frozen_string_literal: true

module Eventure
  module Repository
    # repository for tags
    class Tags
      def self.find_or_create(entity)
        tag_value = entity.tag
        Database::TagOrm.first(tag: tag_value) ||
          Database::TagOrm.create(tag: tag_value)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Tag.new(
          id: db_record.id,
          tag: db_record.tag
        )
      end
    end
  end
end
