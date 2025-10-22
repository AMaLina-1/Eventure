# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:activities_relateurls) do
      foreign_key :activity_id, :activities, key: :activity_id, type: Integer, null: false
      foreign_key :relate_url_id, :relateurls, key: :relate_url_id, type: Integer, null: false

      primary_key %i[activity_id relate_url_id]
      index :relate_url_id
    end
  end
end
