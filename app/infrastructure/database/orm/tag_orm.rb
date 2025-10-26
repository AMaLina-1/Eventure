# frozen_string_literal: true

require 'sequel'

module Eventure
  module Database
    # Object-Relational Mapper for Tags
    class TagOrm < Sequel::Model(:tags)
      unrestrict_primary_key
      many_to_many :activities,
                   class: :'Eventure::Database::ActivityOrm',
                   join_table: :activities_tags,
                   left_key: :tag_id, right_key: :activity_id
    end
  end
end
