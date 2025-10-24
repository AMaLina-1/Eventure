# frozen_string_literal: true

module Eventure
  module Entity
    class Relatedata
      attr_accessor :id, :relate_title, :relate_url

      def initialize(id:, relate_title:, relate_url:)
        @id = id
        @relate_title = relate_title
        @relate_url = relate_url
      end
    end
  end
end