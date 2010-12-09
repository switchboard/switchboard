class Attachment < ActiveRecord::Base
  belongs_to :lists
  has_attachment :storage => :db_file

  validates_as_attachment

end
