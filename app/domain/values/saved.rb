# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Value
    class Saved < Dry::Struct
      include Dry.Types()

      attribute :is_saved, Strict::Bool

      def saved? 
        is_saved
      end

      def to_s
        is_saved.to_s
      end

      def ==(other)
        other.is_a?(Saved) && other.is_saved == is_saved 
      end
    end
  end
end
