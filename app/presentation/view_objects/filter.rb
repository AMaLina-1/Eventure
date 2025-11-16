# frozen_string_literal: true

require_relative 'activity'

module Views
  # View for selected filter parameters
  class Filter
    def initialize(filter)
      @filter = filter
    end

    def tags
      @filter.tag.uniq
    end

    def city
      @filter.city
    end

    def districts
      @filter.districts.uniq
    end

    def start_date
      @filter.start_date
    end

    def end_date
      @filter.end_date
    end
  end
end
