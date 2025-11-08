# frozen_string_literal: true

module Views
  # View for a single activity entity
  class Activity
    def initialize(activity)
      @activity = activity
    end

    def serno
      @activity.serno
    end

    def name
      @activity.name
    end
    
    def detail
      @activity.detail
    end

    def location
      "#{@activity.city}#{@activity.district}#{@activity.building}"
    end

    def voice
      @activity.voice
    end

    def organizer
      @activity.organizer
    end

    ###
    def tag_ids
    #   @activity.tag_ids
      @activity.tags.map { |tag| tag.tag_id }
    end

    def tags
      @activity.tags.map { |tag| tag.tag }
    end

    def relate_data_title
      @activity.relate_data.map { |data| data.relate_title }
    end

    def relate_data_url
      @activity.relate_data.map { |data| data.relate_url }
    end

    def start_date
      @activity.activity_date.start_time
    end

    def end_date
      @activity.activity_date.end_time
    end

    def duration
      @activity.activity_date.duration
    end

    def status
      @activity.activity_date.status
    end

    def likes_count
      @activity.likes_count
    end
    # def tags
    #   @activity.serno
    # end


  end
end
