# frozen_string_literal: true

require 'sequel'

module Eventure
  module Database
    # Object-Relational Mapper for Relateruls
    class RelatedataOrm < Sequel::Model(:relatedata)
      many_to_many :activities,
                   class: :'Eventure::Database::ActivityOrm',
                   join_table: :activities_relatedata,
                   left_key: :relatedata_id, right_key: :activity_id
    end
  end
end
