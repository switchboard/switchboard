class ProfilesController < ApplicationController

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update_attributes(params[:user])
      redirect_to edit_profile_path, notice: 'Your profile was saved.'
    else
      render :edit, alert: 'There was a problem updating your profile; check the fields below for errors.'
    end
  end

end
