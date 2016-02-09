class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  before_filter :get_list
  before_filter :require_user

  helper_method :current_user, :signed_in?, :current_organization, :current_list
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

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


  def format_phone(num)
    return num if num == 'Web'
    num = num.to_s.gsub(/^\+1/,'').gsub(/[^0-9]/, '')
    if num.length == 10
      num = "#{num[0..2]}.#{num[3..5]}.#{num[6..9]}"
    end
    num
  end
  helper_method :format_phone

  protected

  def current_user
    @current_user ||= begin
      if cookies[:auth_token]
        user = User.find_by_auth_token(cookies[:auth_token])
        cookies.delete(:auth_token) if ! user
        Time.zone = user.time_zone if user
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

  def require_admin(notice = 'You must be an admistrator to access that page.')
    unless current_user && current_user.superuser?
      store_location
      flash[:notice] = notice
      redirect_to signin_path
      return false
    end
  end

  def current_organization
    @current_organization ||= begin
      if current_user
        current_user.default_organization
      else
        nil
      end
    end
  end

  def switch_organization(organization)
    @current_organization = organization
    current_user.update_column(:default_organization_id, organization.id)
  end

  def render_404
    respond_to do |type|
      type.html { render file: Rails.public_path + '/404', formats: [:html], status: 404, layout: false }
      type.all  { render nothing: true, status: 404 }
    end
    true  # so we can return "render_404"
  end

  def current_list
    @list
  end

  private

  def get_list
    return nil unless current_organization && params[:list_id]
    @list = current_organization.lists.find_by_id(params[:list_id])
  end

end
