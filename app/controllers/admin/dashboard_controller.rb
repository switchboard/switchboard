class Admin::DashboardController < AdminController

  def index
    @messages = Message.order('created_at DESC').limit(10)
  end
end
