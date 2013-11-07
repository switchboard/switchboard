class ListMembership < ActiveRecord::Base
  attr_accessor :skip_destroy_notification, :join_locale

  belongs_to :phone_number
  belongs_to :list

  attr_accessible :phone_number_id, :join_locale

  validates :phone_number_id, uniqueness: {scope: :list_id}
  after_create :send_welcome_message

  scope :admin, where(is_admin: true)

  def send_welcome_message
    list.send_welcome_message(phone_number, join_locale)
  end

end
