# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:relatedata) do
      primary_key :relatedata_id
      String :relate_title, null: true
      String :relate_url, null: true
    end
  end
end
