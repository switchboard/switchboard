class PasswordResetsController < ApplicationController
  skip_before_filter :require_user
  layout 'login'

  def create
    user = User.find_by_email(params[:password_reset][:email])
    if user
      user.send_password_reset
      redirect_to signin_path, notice: 'OK, we sent you an email with password reset instructions.'
    else
      flash.now[:notice] = 'We could not find that user in our system.'
      render :new
    end
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:id])
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < 2.hours.ago
      redirect_to new_password_reset_path, alert: 'Password Reset has expired for security; you can reset it again if you like.'
    elsif @user.update_attributes(params[:user])
      redirect_to signin_path, notice: 'Your password was reset. You will need to sign in again.'
    else
      flash.now[:alert] = 'Your password was invalid.'
      render :edit
    end
  end
end
