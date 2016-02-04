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

  # Organization count is run after List count, so we can
  # just count the total of the lists
  def sms_count_for_rollup
    lists_including_deleted.inject(0){|sum, list| sum += list.last_month_sms }
  end

  def current_month_sms
    lists_including_deleted.inject(0){|sum, list| sum += list.current_month_sms }
  end
end
