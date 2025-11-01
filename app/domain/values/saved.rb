# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Value
    class Saved < Dry::Struct
      include Dry.Types()

      attribute :saved, Strict::Bool

      def is_saved? 
        saved
      end

      def saved_count
        saved ? 1 : 0
      end

      def to_s
        saved.to_s
      end

      def ==(other)
        other.is_a?(Saved) && other.saved == saved 
      end
    end
  end
end
