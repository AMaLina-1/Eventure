# frozen_string_literal: true

module Eventure
  module Entity
    class Tag
      attr_accessor :id, :tag

      def initialize(id:, tag:)
        @id = id
        @tag = tag
      end
    end 
  end
end