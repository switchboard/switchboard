class User < ActiveRecord::Base

  has_many :phone_numbers

  acts_as_authentic do |c|
    c.validate_password_field = false
    c.validate_email_field = false
    c.validate_login_field = false
  end

  validates_format_of :email, :with => /^\S+@[\w\-\.]+$/, :message => 'Invalid email address', :allow_blank => 1

  def make_admin
    self.update_attribute(:admin => 1)
  end

  def is_admin?
    self.admin
  end

end
