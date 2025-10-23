# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:activities_relateurls) do
      foreign_key :activity_id, :activities, key: :activity_id, type: Integer, null: false
      foreign_key :relatedata_id, :relatedata, key: :relatedata_id, type: Integer, null: false

      primary_key %i[activity_id relatedata_id]
      index :relatedata_id
    end
  end
end
