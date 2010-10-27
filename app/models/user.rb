class User < ActiveRecord::Base

  has_many :phone_numbers
  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id'
  has_many :received_messages, :class_name => 'Message', :foreign_key => 'recipient_id' 
 
  acts_as_authentic do |c|
    #c.validate_password_field = false  <--- this breaks the creation of seed data
    c.ignore_blank_passwords = true
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
