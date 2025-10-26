# frozen_string_literal: true

require 'sequel'

module Eventure
  module Database
    # Object-Relational Mapper for Activities
    class ActivityOrm < Sequel::Model(:activities)
      many_to_many :tags,
                   class: :'Eventure::Database::TagOrm',
                   join_table: :activities_tags,
                   left_key: :activity_id, right_key: :tag_id

      many_to_many :relatedata,
                   class: :'Eventure::Database::RelatedataOrm',
                   join_table: :activities_relatedata,
                   left_key: :activity_id, right_key: :relatedata_id
    end
  end
end
