# frozen_string_literal: true

Sequel.migration do # rubocop:disable Metrics/BlockLength
  change do # rubocop:disable Metrics/BlockLength
    create_table(:activities) do
      primary_key :activity_id
      Integer :serno, null: true
      String :name, null: false
      Text :detail, null: true
      DateTime :start_time, null: true
      DateTime :end_time, null: true
      String :location, null: true
      Text :voice, null: true
      String :organizer, null: true

      index %i[start_time end_time]
    end
    # 非 NULL 的 serno 要唯一（UPSERT 去重）
    # run <<~SQL
    #   CREATE UNIQUE INDEX IF NOT EXISTS uniq_activities_serno_not_null
    #   ON activities(serno) WHERE serno IS NOT NULL;
    # SQL

    # # 時間基本合法性
    # run <<~SQL
    #   ALTER TABLE activities
    #   ADD CONSTRAINT IF NOT EXISTS chk_activities_dates
    #   CHECK (end_time IS NULL OR start_time IS NULL OR end_time >= start_time);
    # SQL

    # # ——關鍵字搜尋（subject/detailcontent）——
    # run 'CREATE EXTENSION IF NOT EXISTS pg_trgm;'
    # run <<~SQL
    #   CREATE INDEX IF NOT EXISTS idx_activities_subject_trgm
    #   ON activities USING GIN (subject gin_trgm_ops);
    # SQL
    # run <<~SQL
    #   CREATE INDEX IF NOT EXISTS idx_activities_detail_trgm
    #   ON activities USING GIN (details gin_trgm_ops);
    # SQL
  end
end
