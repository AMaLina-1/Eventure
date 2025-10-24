# frozen_string_literal: true

module Eventure 
  module Repository
    class Activities 
      def self.all
        Database::ActivityOrm.all.map { |db_activity| rebuild_entity(db_activity) }
      end

      def self.find_serno(serno)
        db_record = Database::ActivityOrm.first(serno: )
        rebuild_entity(db_record)
      end

      def self.create(entity)
        db_activity = Database::ActivityOrm.create(
          serno: entity.serno,
          name: entity.name,
          detail: entity.detail,
          start_time: entity.start_time,
          end_time: entity.end_time,
          location: entity.location,
          voice: entity.voice,
          organizer: entity.organizer
        )

        entity.tags.each do |tag|
          db_tag = Tags.find_or_create(tag)
          db_activity.add_tag(db_tag)
        end

        entity.relate_data&.each do |relateurl|
          db_relateurl = Relatedata.find_or_create(relateurl)
          db_activity.add_relatedata(db_relateurl)
        end

        rebuild_entity(db_activity)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Activity.new(
          serno: db_record.serno,
          name: db_record.name,
          detail: db_record.detail,
          start_time: db_record.start_time,
          end_time: db_record.end_time,
          location: db_record.location,
          voice: db_record.voice,
          organizer: db_record.organizer,
          tags: db_record.tags.map { |db_tag| Tags.rebuild_entity(db_tag) },
          relate_data: db_record.relatedata.map { |db_relateurl| Relatedata.rebuild_entity(db_relateurl) }
        )
      end
    end
  end
end
