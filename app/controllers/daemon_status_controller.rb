class DaemonStatusController < ApplicationController
    def alert
      status = DaemonStatus.find(:first, :order => "updated_at desc", :limit => 1)
      updated_at = status.updated_at
      @elapsed_time = Time.now.to_time - updated_at.to_time
      if (@elapsed_time < 60) 
        @alert = false
      else
        @alert = true
      end 
    end
end
