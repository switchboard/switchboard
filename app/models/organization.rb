class Organization < ActiveRecord::Base
  include MonthlyCountable

  has_many :lists, dependent: :destroy, order: :name
  has_many :messages, through: :lists, order: 'created_at DESC'
  has_many :invitations, dependent: :destroy
  has_and_belongs_to_many :users

  attr_accessible :name

  validates :name, presence: true

  def lists_including_deleted
    List.unscoped { lists.reload }
  end

  def invite_user_by_email(email)
    if user = User.find_by_email(email)
      self.users << user
      UserMailer.added_to_organization(user, self).deliver
    else
      invitation = invitations.create(email: email)
      UserMailer.invited_to_organization(invitation, self).deliver
    end
  end

  def sms_count
    lists_including_deleted.inject(0){|sum, list| sum += list.sms_count }
  end
end
