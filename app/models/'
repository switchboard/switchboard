class PhoneNumber < ActiveRecord::Base
  has_many :list_memberships
  has_many :lists, :through => :list_memberships

  def add_to_list(list)
    self.list_memberships.create! :list => list
  end
end
