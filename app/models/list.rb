class List < ActiveRecord::Base

  validates_presence_of :name
  has_many :list_memberships
  has_many :phone_numbers, :through => :list_memberships
 

  ## 
  ## TODO: decide if these receive objects or strings or are flexible?
  ## for now: take objects

  def add_phone_number(phone_number)
    self.list_memberships.create! :phone_number_id => phone_number.id
  end

  def remove_phone_number(phone_number)
    return unless self.has_number?(phone_number)
    self.list_memberships.find_by_phone_number_id(phone_number.id).destroy!
  end

  def has_number?(phone_number)
    self.list_memberships.exists?(:phone_number_id => phone_number.id)
  end

end
