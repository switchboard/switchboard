class PhoneNumber < ActiveRecord::Base
  has_many :list_memberships
  has_many :lists, :through => :list_memberships
  belongs_to :user

  def add_to_list(list)
    self.list_memberships.create! :list => list
  end

  def display_number_with_name
    if self.user and !self.user.first_name.empty?
      display_name = " (#{self.user.first_name})"
    else
      display_name = ""
    end
    self.number + display_name 
  end

end
