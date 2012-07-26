class ListMembership < ActiveRecord::Base
  attr_accessor :skip_destroy_notification

  belongs_to :phone_number
  belongs_to :list

  attr_accessible :phone_number_id
  attr_accessible :is_admin, as: :admin

end
