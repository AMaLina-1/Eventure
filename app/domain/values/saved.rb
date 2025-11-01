# frozen_string_literal: true

module Eventure
  module Value
    class Saved 
      attr_reader :is_saved

      def initialize(is_saved)
        @is_saved = is_saved
      end

      def saved? 
        @is_saved == true
      end

      def to_s
        @is_saved.to_s
      end

      def ==(other)
        other.class == self.class && other.is_saved == @is_saved  
      end
    end
  end
end
