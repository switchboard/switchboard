class Contact < ActiveRecord::Base

  has_many :phone_numbers

  accepts_nested_attributes_for :phone_numbers
  validates_associated  :phone_numbers

  attr_accessible :first_name, :last_name, :email
  attr_accessible :phone_numbers_attributes

  validates_format_of :email, with: /^\S+@[\w\-\.]+$/, message: 'Invalid email address', allow_blank: true

  before_save :calculate_full_name

  private

  def calculate_full_name
    self.full_name = [first_name, last_name].join(' ').strip
  end
end
