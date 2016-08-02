class SentTwilioMessage < ActiveRecord::Base
  attr_accessible :account_id, :created_at, :error_code, :list_id, :status, :to, :twilio_id

  def self.update_all
    where('status is NULL').each do |message|
      TwilioClient.update_logged_message_status(message)
    end
  end
end
