module Pipely
  module Build

    # Compute schedule attributes for a pipeline that runs once-a-day at a set
    # time.
    #
    class DailyScheduler
      attr_accessor :period

      def initialize(start_time, period)
        @start_time = start_time
        @period = period || '24 Hours'
      end

      def start_date_time
        date = Date.today

        # if start_time already happened today, wait for tomorrow's start_time
        now_time = Time.now.utc.strftime('%H:%M:%S')
        date += 1 if now_time >= @start_time

        date.strftime("%Y-%m-%dT#{@start_time}")
      end

      def to_hash
        {
          :period => period,
          :start_date_time => start_date_time
        }
      end

    end

  end
end
