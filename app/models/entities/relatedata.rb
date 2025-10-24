# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Entity
    # Domain entity for related data
    class Relatedata < Dry::Struct
      include Dry.Types

      attribute :id,           Strict::Integer
      attribute :relate_title, Strict::String
      attribute :relate_url,   Strict::String
    end
  end
end
