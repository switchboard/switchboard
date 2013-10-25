namespace :message_counts do
  desc 'Save monthly counts'
  task monthly: :environment do
    List.calculate_monthly_stats
    Organization.calculate_monthly_stats
  end
end