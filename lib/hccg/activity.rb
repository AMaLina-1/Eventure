# frozen_string_literal: true

module Eventure
  # Wrap a raw activity hash and expose the 11 fields as methods
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

    def initialize(raw)
      @raw = raw
    end

    FIELDS.each do |field|
      define_method(field) do
        @raw[field] || @raw[field.to_sym]
      end
    end
  end
end
