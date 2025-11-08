# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'
require 'date'

module Eventure
  module Value
    # Duration value object
    class ActivityDate < Dry::Struct
      include Dry.Types()

      attribute :start_time,   Strict::DateTime
      attribute :end_time,     Strict::DateTime

      def duration
        diff = ((end_time - start_time) * 24 * 60).to_i
        day, remain = diff.divmod(24 * 60)
        hour, minute = remain.divmod(60)
        "#{day} days #{hour} hours #{minute} minutes"
      end

      def status
        now = ::DateTime.now
        return check_past(now, 3) if end_time < now

        return check_future(now, 7) if now < start_time

        'Ongoing'

        # Archived:  end_time < now - 3
        # Expired:   now - 3 <= end_time && end_time <= now
        # Ongoing:   start_time <= now && now < end_time
        # Upcoming:  now < start_time && start_time <= now + 7
        # Scheduled: now + 7 < start_time
      end

      # private
      def check_past(now, offset)
        end_time < now - offset ? 'Archived' : 'Expired'
      end

      def check_future(now, offset)
        now + offset < start_time ? 'Scheduled' : 'Upcoming'
      end

      def ==(other)
        other.instance_of?(self.class) && start_time == other.start_time && end_time == other.end_time
      end
    end
  end
end
