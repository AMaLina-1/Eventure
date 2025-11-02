# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:activities) do
      add_column :likes_count, :Bignum, default: 0, null: false
    end
  end
end
