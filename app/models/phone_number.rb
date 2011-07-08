class PhoneNumber < ActiveRecord::Base
  has_many :list_memberships
  has_many :lists, :through => :list_memberships
  belongs_to :user

  validates_format_of :number, :with => /^\d{10}$/, :message => "Phone number must contain 10 digits with no extra characters"

  def add_to_list(list)
    self.list_memberships.create! :list => list
  end

  def display_number_with_name
    text = "" 
    if self.user and !self.user.first_name.nil?
      text = "#{self.user.first_name}"
    end
    
    if text == ''
      text = self.number
    else
      text = text + ": " + self.number
    end
    text
  end

  def can_receive_email?
    return ! self.provider_email.blank?
  end

  def can_receive_gateway?
    return true
  end

end
