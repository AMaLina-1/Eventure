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

    def initialize(raw = {})
      @raw = raw.is_a?(Hash) ? raw : {}
    end

    FIELDS.each do |field|
      define_method(field) do
        @raw[field] || @raw[field.to_sym]
      end
    end

    def to_h
      FIELDS.each_with_object({}) do |key, acc|
        key_sym = key.to_sym
        # Return string keys to match existing fixtures and specs
        acc[key] = @raw[key] if @raw.key?(key)
        acc[key] = @raw[key_sym] if !acc.key?(key) && @raw.key?(key_sym)
      end
    end

    # Backwards-compatible hash-like access (e.g. obj['subject'])
    def [](key)
      key_s = key.to_s
      key_sym = key.to_sym
      return @raw[key_s] if @raw.key?(key_s)
      return @raw[key_sym] if @raw.key?(key_sym)

      # fallback to field methods
      send(key_s) if FIELDS.include?(key_s)
    end
  end
end
