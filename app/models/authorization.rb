class Authorization < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, scope: :provider

  DISPLAY_NAMES = {'google_oauth2' => 'Google', 'facebook' => 'Facebook' }

  def self.find_from_hash(hash)
    find_by_provider_and_uid(hash['provider'], hash['uid'].to_s)
  end

  def self.create_from_hash(hash, user = nil)
    begin
      user ||= User.create_from_hash!(hash)
    rescue => e
      raise Exceptions::UserExists
    end
    Authorization.create(user: user, uid: hash['uid'], provider: hash['provider'], email: hash[:info][:email])
  end
  
end