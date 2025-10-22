# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:relateurls) do
      primary_key :relate_url_id
      String :relate_url, null: true
    end
  end
end
