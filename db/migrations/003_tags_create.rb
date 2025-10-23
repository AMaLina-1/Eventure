# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:tags) do
      Integer :tag_id, primary_key: true
      String :tag, null: true
    end
  end
end
