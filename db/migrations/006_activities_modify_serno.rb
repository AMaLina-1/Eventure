# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:activities) do
      set_column_type :serno, :bigint
    end
  end
end
