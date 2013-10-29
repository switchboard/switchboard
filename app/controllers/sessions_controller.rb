class SessionsController < ApplicationController
  skip_before_filter :require_user
  layout 'login'

  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      sign_in(user, permanent: params[:remember_me])

      user.update_attribute(:password_reset_token, nil)
      redirect_back_or_default lists_path, notice: "You're signed into your Switchboard account."
    else
      flash.now.alert = "Invalid email or password"
      render :new
    end
  end

  def destroy
    User.find_by_auth_token(cookies.delete(:auth_token)).try(:reset_auth_token)
    cookies.delete(:username)
    redirect_to signin_path, notice: "You're signed out of your Switchboard account."
  end
end
