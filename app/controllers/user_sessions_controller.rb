class UserSessionsController < ApplicationController
  #before_filter :require_no_user, :only => [:new, :create]
  #before_filter :require_user, :only => :destroy

  layout "login"
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    if params[:user_session][:login] == 'admin'
      @user_session = UserSession.new(params[:user_session])
      if @user_session.save
        flash[:notice] = "You are logged in!  Get started by selecting a list." 
        redirect_to root_url
      else
        render :action => :new
      end
    else
      flash[:notice] = "This user cannot log in."
    end
  end
  
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to new_user_sessions_url
  end
end
