# frozen_string_literal: true

require_relative 'activity'

module Views
  # View for selected filter parameters
  class Filter
    def initialize(filter_hash)
      @filter = filter_hash || {}
    end

    def tags
      Array(@filter[:tag]).map(&:to_s).uniq
    end

    def city
      @filter[:city].to_s
    end

    def districts
      Array(@filter[:districts]).map(&:to_s).uniq
    end

    def start_date
      @filter[:start_date].to_s
    end

    def end_date
      @filter[:end_date].to_s
    end
  end
end
