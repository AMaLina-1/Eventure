# frozen_string_literal: true

module Eventure
  module Repository
    class Tags 
      def self.find_or_create(entity)
        db_record = Database::TagOrm.first(tag: entity.tag) ||
                    Database::TagOrm.create(tag: entity.tag)
        db_record
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