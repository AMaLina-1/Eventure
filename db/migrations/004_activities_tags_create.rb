# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:activities_tags) do
      foreign_key :activity_id, :activities, key: :activity_id, type: Integer, null: false
      foreign_key :tag_id, :tags, key: :tag_id, type: Integer, null: false

      primary_key %i[activity_id tag_id]
      index :tag_id
    end
  end
end
