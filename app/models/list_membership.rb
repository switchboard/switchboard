class ListMembership < ActiveRecord::Base
  attr_accessor :skip_destroy_notification

  belongs_to :phone_number
  belongs_to :list

  attr_accessible :phone_number_id

  validates :phone_number_id, uniqueness: {scope: :list_id}
  after_create :send_welcome_message
  
  
  def send_welcome_message
    list.send_welcome_message(phone_number)
  end

end
