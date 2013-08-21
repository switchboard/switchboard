class Contact < ActiveRecord::Base

  has_many :phone_numbers
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id' 

  accepts_nested_attributes_for :phone_numbers
  validates_associated  :phone_numbers

  attr_accessible :first_name, :last_name, :email
  attr_accessible :phone_numbers_attributes

  validates_format_of :email, with: /^\S+@[\w\-\.]+$/, message: 'Invalid email address', allow_blank: true 

  def make_admin
    self.update_attribute(:admin => 1)
  end

  def is_admin?
    self.admin
  end

  def full_name
    [first_name, last_name].join(' ').strip
  end
end