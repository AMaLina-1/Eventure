# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module Eventure
  module Value
    # Saved value object
    class Saved < Dry::Struct
      include Dry.Types()

      attribute :saved, Strict::Array.of(Strict::String)

      def saved?(id)
        saved.include?(id.to_s)
      end

      def saved_count
        saved.count
      end

      def to_s
        saved.join(', ')
      end

      def ==(other)
        self.class == other.class && saved == other.saved
      end
    end
  end
end
