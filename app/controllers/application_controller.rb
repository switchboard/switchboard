class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  before_filter :get_list


  helper_method :current_user, :signed_in?
  # This is shared between auth & providers controller
  def sign_in(user, opts = {})
    if opts[:permanent]
      cookies.permanent[:auth_token] = user.auth_token
      cookies.permanent[:username] = {
               :value => user.name
             }

    elsif opts[:provider]
      cookies[:auth_token] = { value: user.auth_token, expires: 1.week.from_now }
    else
      cookies[:auth_token] = user.auth_token
      cookies[:username] = { :value => user.name }
    end
  end


  # store a return_to location, but only if this was a GET request.
  # We can return to this location by calling #redirect_back_or_default.
  def store_location(custom_location = nil)
    session[:return_to] = custom_location || (request.get? ? request.url : nil)
  end
  
  def redirect_back_or_default(default = nil, opts = {})
    redirect_to((session[:return_to] || default || root_path), opts)
    session[:return_to] = nil
  end


  protected

  def current_user
    @current_user ||= begin
      if cookies[:auth_token]
        user = User.find_by_auth_token(cookies[:auth_token])
        cookies.delete(:auth_token) if ! user
        user
      end
    end
  end

  def signed_in?
    !!current_user
  end

  def require_user(notice = 'You must be signed in to access that page.')
    unless current_user
      store_location
      flash[:notice] = notice
      redirect_to signin_path
      return false
    end
  end

  private

  def get_list
    @list = List.find_by_id(params[:list_id] || params[:id])
  end

end
