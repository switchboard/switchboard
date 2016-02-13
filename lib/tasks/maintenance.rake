namespace :maintenance do

  desc 'Ignore old unconfirmed messages'
  task ignore_unconfirmed: :environment do
    Message.needs_confirmation.where('created_at < ?', Settings.message_confirmation_time.minutes.ago).update_all("aasm_state='ignored'")
  end

end