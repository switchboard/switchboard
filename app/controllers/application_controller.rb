# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details


  helper_method :current_user_session, :current_user

  before_filter :get_list

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def require_admin
      unless (current_user and current_user.is_admin?)
        flash[:notice] = "You are not authorized to view that page."
        redirect_to new_user_sessions_url
      end
    end

    def get_list
      @list = List.find_by_id(params[:list_id] || params[:id])
    end

end
