namespace :message_counts do
  desc 'Save monthly counts'
  task monthly: :environment do
    List.calculate_monthly_stats
    Organization.calculate_monthly_stats
    List.all.each do |list|
      list.clear_current_sms
    end
  end

  desc 'Clear monthly counts'
  task clear: :environment do
    SentCount.destroy_all
    List.all.each do |list|
      list.clear_current_sms
    end
  end
end