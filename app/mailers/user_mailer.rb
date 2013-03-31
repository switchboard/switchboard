class UserMailer < ActionMailer::Base
  default from: "switchboard@mediamobilizing.org"

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "[Switchboard] Password Reset"
  end

end
