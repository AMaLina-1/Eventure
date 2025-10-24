# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Entity
    # Domain entity for a tag
    class Tag < Dry::Struct
      include Dry.Types

      attribute :id,  Strict::Integer
      attribute :tag, Strict::String
    end
  end
end
