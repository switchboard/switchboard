class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation, :current_password

  has_many :authorizations, dependent: :destroy

  attr_accessor :current_password

  validates :name, presence: true
  validates :email, presence: true, confirmation: true, email_format: true, uniqueness: { message: "There was a problem creating an account with that email address; maybe you already have an account?"}

  validates :password, {
    :presence => true,
    :confirmation => true,
    :length => {:minimum => 6, :allow_blank => false},
    :if => Proc.new { |u| u.new_record? || u.current_password.present? || u.password_reset_token.present? }
  }

  has_secure_password
  before_create { generate_token(:auth_token) }

  def self.authenticate(email, password)
    find_by_email(email).try(:authenticate, password)
  end

  def self.create_from_hash!(hash)
    create! do |user|
      user.email    = hash[:info][:email]
      user.name    = hash[:info][:name]
      user.password = user.password_confirmation = SecureRandom.hex(15)
    end
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(validate: false)
    UserMailer.password_reset(self).deliver
  end

  def reset_auth_token
    generate_token(:auth_token)
    update_attribute(:auth_token, self.auth_token)
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64(32)
    end while User.exists?(column => self[column])
  end

end
