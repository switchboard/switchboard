class RegistrationController < ApplicationController
  skip_before_filter :require_user

  layout 'login'

  def new_invited
    @invitation = Invitation.find_by_token(params[:invitation_token])
    if ! @invitation
      redirect_to signin_path, alert: 'That invitation cannot be found; did you already sign up? Check your link again, or request a new invitation.' and return
    elsif current_user
      redirect_to lists_path, notice: "You're already signed-in to Switchboard!"
    end
    @user = @invitation.organization.users.build(email: @invitation.email)
  end

  def create
    @invitation = Invitation.find_by_token(params[:invitation_token])
    @user = User.new(params[:user])

    if @user.save
      @user.organizations << @invitation.organization
      @invitation.destroy
      cookies[:auth_token] = @user.auth_token
      redirect_to lists_path, notice: "You're signed up. Welcome to Switchboard!"
    else
      render :new_invited
    end
  end

end