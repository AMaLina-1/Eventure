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
      @raw = raw || {}
    end

    FIELDS.each do |f|
      define_method(f) do
        @raw[f] || @raw[f.to_sym]
      end
    end

    def to_h
      FIELDS.each_with_object({}) do |k, acc|
        # Return string keys to match existing fixtures and specs
        acc[k] = @raw[k] if @raw.key?(k)
        acc[k] = @raw[k.to_sym] if !acc.key?(k) && @raw.key?(k.to_sym)
      end
    end

    # Backwards-compatible hash-like access (e.g. obj['subject'])
    def [](key)
      key_s = key.to_s
      return @raw[key_s] if @raw.key?(key_s)
      return @raw[key.to_sym] if @raw.key?(key.to_sym)

      # fallback to field methods
      send(key_s) if FIELDS.include?(key_s)
    end
  end
end
