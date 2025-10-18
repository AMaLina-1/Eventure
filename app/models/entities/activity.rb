# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Entity
    # Domain entity for an activity
    class Activity < Dry::Struct
      include Dry.Types

      attribute :publish_unit,  Strict::String
      attribute :subject,       Strict::String
      attribute :details,       Strict::String
      attribute :subject_class, Strict::Array.of(String)
      attribute :service_class, Strict::Array.of(String)
      attribute :voice,         Strict::String
      attribute :host,          Strict::String
      attribute :join,          String.optional
      attribute :start_time,    Strict::DateTime
      attribute :end_time,      Strict::DateTime
      attribute :place,         Strict::String
    end
  end
end
