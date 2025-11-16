# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

module Eventure
  module Value
    # value object for activities
    class Location < Dry::Struct
      include Dry.Types

      attribute :building, Strict::String

      def to_s
        building
      end

      def city
        '新竹市'
        # use to_s at the end
      end

      def district
        '東區'
        # use to_s at the end
      end
    end
  end
end
