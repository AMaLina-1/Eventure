# frozen_string_literal: true

module Eventure
  module Database
    # Object-Relational Mapper for Activities
    class ActivityOrm < Sequel::Model(:activities)
      many_to_many :tags,
                   class: :'Eventure::Database::TagOrm',
                   join_table: :activities_tags,
                   left_key: :activity_id, right_key: :tag_id

      many_to_many :relateurls,
                   class: :'Eventure::Database::RelateurlOrm',
                   join_table: :activities_relateurls,
                   left_key: :activities_id, right_key: :relate_url_id
    end
  end
end
