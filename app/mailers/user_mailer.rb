class UserMailer < ActionMailer::Base
  default from: "switchboard@mediamobilizing.org"

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "[Switchboard] Password Reset"
  end

  def added_to_organization(user, organization)
    @user = user
    @organization = organization
    mail to: user.email, subject: "[Switchboard] You were added to #{organization.name}"
  end

  def invited_to_organization(invitation, organization)
    @invitation = invitation
    @organization = organization
    mail to: invitation.email, subject: "[Switchboard] #{organization.name} invited you to join Switchboard"
  end

end
