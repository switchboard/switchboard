class UserSessionsController < ApplicationController
#  before_filter :require_no_user, :only => [:new, :create]
#  before_filter :require_user, :only => :destroy

  layout "login"
  
  def new
    @user_session = UserSession.new
  end
  
  def create
    if params[:user_session][:login] == 'admin'
      @user_session = UserSession.new(params[:user_session])
      if @user_session.save
        flash[:notice] = "Login successful!"
        redirect_to :controller => 'admin', :action => 'manage' 
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
    redirect_to new_user_session_url
  end
end
