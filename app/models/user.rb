class User < ActiveRecord::Base

  has_many :phone_numbers
  has_many :sent_messages, :class_name => 'Message', :foreign_key => 'sender_id'
  has_many :received_messages, :class_name => 'Message', :foreign_key => 'recipient_id' 

  accepts_nested_attributes_for :phone_numbers
  validates_associated  :phone_numbers

  attr_accessible :first_name, :last_name, :email
  attr_accessible :phone_numbers_attributes

  acts_as_authentic do |c|
    #c.validate_password_field = false  <--- this breaks the creation of seed data
    c.merge_validates_length_of_password_field_options( {
      if: :is_admin?
    })
    c.ignore_blank_passwords = true
    c.validate_email_field = false
    c.validate_login_field = false
  end

  validates_format_of :email, :with => /^\S+@[\w\-\.]+$/, :message => 'Invalid email address', :allow_blank => true 

  def make_admin
    self.update_attribute(:admin => 1)
  end

  def is_admin?
    self.admin
  end

  def full_name
    [first_name, last_name].join(' ')
  end
end
