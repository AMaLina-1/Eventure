# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Value
    # Saved value object
    class Saved < Dry::Struct
      include Dry.Types()

      attribute :saved, Strict::Bool

      def saved?
        saved
      end

      def saved_count
        saved ? 1 : 0
      end

      def to_s
        saved.to_s
      end

      def ==(other)
        self.class == other.class && saved == other.saved
      end
    end
  end
end
