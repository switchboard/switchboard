class User < ActiveRecord::Base

  has_many :phone_numbers

  validates_format_of :email, :with => /^\S+@[\w\-\.]+$/, :message => 'Invalid email address', :allow_blank => 1

end
