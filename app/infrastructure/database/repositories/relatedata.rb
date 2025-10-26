# frozen_string_literal: true

module Eventure
  module Repository
    # repository for Relatedata entity
    class Relatedata
      def self.find_or_create(entity)
        title = entity.relate_title
        url   = entity.relate_url

        Database::RelatedataOrm.first(
          relate_title: title,
          relate_url: url
        ) || Database::RelatedataOrm.create(
          relate_title: title,
          relate_url: url
        )
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::RelateData.new(
          relatedata_id: db_record.id,
          relate_title: db_record.relate_title,
          relate_url: db_record.relate_url
        )
      end
    end
  end
end
