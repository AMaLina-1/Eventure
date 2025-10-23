# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Entity
    # Domain entity for an activity
    class Activity < Dry::Struct
      include Dry.Types

      attribute :serno,        Strict::Integer
      attribute :name,         Strict::String
      attribute :detail,       Strict::String
      attribute :start_time,   Strict::DateTime
      attribute :end_time,     Strict::DateTime
      attribute :location,     Strict::String
      attribute :voice,        Strict::String
      attribute :organizer,    Strict::String
      attribute :tag_id,       Strict::Array.of(Integer)
      attribute :tag,          Strict::Array.of(String)
      attribute :relate_url,   Strict::Array.of(String)
      attribute :relate_title, Strict::Array.of(String)
    end
  end
end
