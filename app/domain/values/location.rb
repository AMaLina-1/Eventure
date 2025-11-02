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
      end

      def district
        '東區'
      end
    end
  end
end
