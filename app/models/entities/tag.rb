# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

module Eventure
  module Entity
    class Tag < Dry::Struct
      include Dry.Types

      attribute :tag_id, Integer.optional
      attribute :tag,    String
    end
  end
end
