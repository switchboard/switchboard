class Admin::DashboardController < AdminController

  def index
    @messages = Message.order('created_at DESC').limit(20)
  end
end
