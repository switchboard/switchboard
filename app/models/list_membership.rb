class ListMembership < ActiveRecord::Base
  attr_accessor :skip_destroy_notification

  belongs_to :phone_number
  belongs_to :list

end
