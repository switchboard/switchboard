class Invitation < ActiveRecord::Base
  attr_accessible :email
  belongs_to :organization

  before_validation(on: :create) { generate_token(:token) }
  
end
