class OrganizationsController < ApplicationController

  def show
    @organization = current_user.accessible_organizations.find(params[:id])
    @users = @organization.users.order(:name).page(params[:page]).per(13)
  end

  def switch
    @organization = current_user.accessible_organizations.find(params[:id])
    current_user.update_column(:default_organization_id, @organization.id)
    redirect_to lists_path, notice: "You switched to #{@organization.name}."
  end

  def invite
    @organization = current_user.accessible_organizations.find(params[:id])
    if email = params[:invitation][:email]
      @organization.invite_user_by_email(email)
    end
    redirect_to @organization, notice: "We sent an invitation to #{email}."
  end
end