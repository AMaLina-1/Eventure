# frozen_string_literal: true

module Eventure
  module Repository
    # repository for activities
    class Activities
      def self.all
        Database::ActivityOrm.all.map { |db_activity| rebuild_entity(db_activity) }
      end

      def self.find_serno(serno)
        db_record = Database::ActivityOrm.first(serno:)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        db_activity = build_activity_record(entity)
        assign_tags(db_activity, entity.tags)
        assign_related_data(db_activity, entity.relate_data)
        rebuild_entity(db_activity)
      end

      def self.build_activity_record(entity)
        Database::ActivityOrm.create(
          serno: entity.serno,
          name: entity.name,
          detail: entity.detail,
          start_time: entity.start_time,
          end_time: entity.end_time,
          location: entity.location,
          voice: entity.voice,
          organizer: entity.organizer
        )
      end

      def self.assign_tags(db_activity, tags)
        tags.each do |tag|
          db_tag = Tags.find_or_create(tag)
          db_activity.add_tag(db_tag)
        end
      end

      def self.assign_related_data(db_activity, relate_data)
        relate_data&.each do |relate|
          db_relate = Relatedata.find_or_create(relate)
          db_activity.add_relatedata(db_relate)
        end
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Eventure::Entity::Activity.new(
          serno: db_record.serno,
          name: db_record.name,
          detail: db_record.detail,
          start_time: db_record.start_time,
          end_time: db_record.end_time,
          location: db_record.location,
          voice: db_record.voice,
          organizer: db_record.organizer,
          tags: rebuild_tags(db_record.tags),
          relate_data: rebuild_related_data(db_record.relatedata)
        )
      end

      def self.rebuild_tags(db_tags)
        db_tags.map { |tag| Tags.rebuild_entity(tag) }
      end

      def self.rebuild_related_data(db_related)
        db_related.map { |rel| Relatedata.rebuild_entity(rel) }
      end
    end
  end
end
