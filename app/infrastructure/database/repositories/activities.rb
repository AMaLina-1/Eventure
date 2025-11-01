# frozen_string_literal: true

require_relative '../../hccg/mappers/activity_mapper'
require_relative '../../../domain/values/location'

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

      def self.create(entities)
        Array(entities).map do |entity|
          db_activity = find_or_create_activity(entity)
          assign_tags(db_activity, entity.tags)
          assign_relate_data(db_activity, entity.relate_data)
          rebuild_entity(db_activity)
        end
      end

      def self.find_or_create_activity(entity)
        attrs = Eventure::Hccg::ActivityMapper.to_attr_hash(entity)
        db_activity = Eventure::Database::ActivityOrm.first(serno: entity.serno)

        if db_activity
          db_activity.update(attrs)
        else
          db_activity = Eventure::Database::ActivityOrm.create(attrs)
        end

        db_activity
      end

      def self.build_activity_record(entity)
        Database::ActivityOrm.create(
          serno: entity.serno, name: entity.name,
          detail: entity.detail,
          start_time: entity.start_time.to_time.utc,
          end_time: entity.end_time.to_time.utc,
          location: entity.location,
          voice: entity.voice,
          organizer: entity.organizer
        )
      end

      def self.assign_tags(db_activity, tags)
        # return if tags.nil? || tags.empty?

        existing_tag_ids = db_activity.tags.map(&:tag_id)

        Array(tags).each do |tag|
          tag_orm = find_or_create_tag(tag)
          next if existing_tag_ids.include?(tag_orm.tag_id)

          db_activity.add_tag(tag_orm)
        end
      end

      def self.find_or_create_tag(tag)
        if tag.is_a?(Eventure::Entity::Tag)
          tag_id = tag.tag_id
          Database::TagOrm.first(tag_id:) ||
            Database::TagOrm.create(tag_id:, tag: tag.tag)
        else
          Database::TagOrm.first(tag: tag) ||
            Database::TagOrm.create(tag: tag)
        end
      end

      def self.assign_relate_data(db_activity, relate_data)
        return if relate_data.to_a.empty?

        db_activity.reload

        Array(relate_data).each do |relate|
          db_relate = Relatedata.find_or_create(relate)
          db_activity.add_relatedatum(db_relate) unless db_activity.relatedata.include?(db_relate)
        end
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Eventure::Entity::Activity.new(rebuild_entity_attributes(db_record))
      end

      def self.rebuild_entity_attributes(db_record)
        db_tags = db_record.tags

        {
          serno: db_record.serno, name: db_record.name, detail: db_record.detail,
          start_time: build_utc_datetime(db_record.start_time), end_time: build_utc_datetime(db_record.end_time),
          location: rebuild_location(db_record.location), voice: db_record.voice,
          organizer: db_record.organizer,
          tag_ids: rebuild_tag_ids(db_tags), tags: rebuild_tags(db_tags),
          relate_data: rebuild_relate_data(db_record.relatedata)
        }
      end

      def self.rebuild_location(location_string)
        Eventure::Value::Location.new(location_string)
      end

      def self.build_utc_datetime(time)
        Time.utc(
          time.year, time.month, time.day, time.hour, time.min, time.sec
        ).to_datetime
      end

      def self.rebuild_tag_ids(db_tags)
        db_tags.map(&:tag_id)
      end

      def self.rebuild_tags(db_tags)
        db_tags.map do |tag|
          Eventure::Entity::Tag.new(
            tag_id: tag.tag_id,
            tag: tag.tag
          )
        end
      end

      def self.rebuild_relate_data(db_relatedata)
        db_relatedata.map { |rel| Relatedata.rebuild_entity(rel) }
      end
    end
  end
end
