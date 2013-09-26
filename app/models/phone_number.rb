class PhoneNumber < ActiveRecord::Base
  has_many :list_memberships
  has_many :lists, through: :list_memberships
  belongs_to :contact

  attr_accessible :number

  validates :number, uniqueness: true, format: {with: /^\d{10}$/, message: 'Phone number must contain 10 digits with no extra characters'}
  validates_uniqueness_of :number

  def add_to_list(list)
    self.list_memberships.create! :list => list
  end

  def number=(str)
    write_attribute(:number, str.try(:gsub, /[^0-9]/, ''))
  end

  def name_and_number
    if contact && contact.first_name.present?
      "#{contact.first_name}: #{number}"
    else
      number
    end
  end

  def can_receive_email?
    provider_email.present?
  end

  def can_receive_gateway?
    true
  end

end
