# frozen_string_literal: true

module Eventure
  module Database
    # Object-Relational Mapper for Relateruls
    class RelateurlOrm < Sequel::Model(:relateurls)
      many_to_many :activities,
                   class: :'Eventure::Database::ActivityOrm',
                   join_table: :activities_relateurls,
                   left_key: :relate_url_id, right_key: :activities_id
    end
  end
end
