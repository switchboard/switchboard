class DaemonStatusController < ApplicationController
  skip_before_filter :require_user

    def alert
      status = DaemonStatus.order("updated_at DESC").first
      updated_at = status.updated_at
      @elapsed_time = Time.now.to_time - updated_at.to_time
      if (@elapsed_time < 60)
        @alert = false
      else
        @alert = true
      end
    end
    def pingdom
      status = DaemonStatus.order('updated_at DESC').first
      updated_at = status.updated_at
      elapsed_time = Time.now.to_time - updated_at.to_time
      @elapsed_time = sprintf("%.3f", elapsed_time)
      if (elapsed_time < 120)
        @status = "OK"
      else
        @status = "service is down"
      end
    end
end
