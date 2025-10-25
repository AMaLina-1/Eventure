# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

module Eventure
  module Entity
    # Domain Entity for related data
    class RelatedData < Dry::Struct
      include Dry.Types

      attribute :relatedata_id, Integer.optional
      attribute :relate_title,  String
      attribute :relate_url,    String
    end
  end
end
