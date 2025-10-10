# frozen_string_literal: true

module HccgEventure
  # 只處理資料解析／欄位存取
  class Activity
    FIELDS = %w[
      pubunitname
      subject
      detailcontent
      subjectclass
      serviceclass
      voice
      hostunit
      joinunit
      activitysdate
      activityedate
      activityplace
    ].freeze

    attr_reader(*FIELDS.map(&:to_sym))

    def initialize(raw_hash)
      FIELDS.each do |k|
        val = raw_hash[k] || raw_hash[k.to_sym]
        instance_variable_set(:"@#{k}", val)
      end
    end

    def to_h
      FIELDS.to_h { |k| [k.to_sym, instance_variable_get(:"@#{k}")] }
    end

    def to_json(*)
      to_h.to_json
    end
  end
end
