# frozen_string_literal: true

require_relative 'activity'

module Views
  # View for a list of activity entities
  class ActivityList
    include Enumerable

    def initialize(activites)
      @activites = activites.map { |activity| Activity.new(activity) }
    end

    def any?
      @activites.any?
    end

    def each(&block)
      @activites.each { |activity| block.call(activity) } if block
    end
  end
end
