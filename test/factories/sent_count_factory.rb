FactoryGirl.define do
  factory :sent_count do
    date_ending { 2.months.ago.end_of_month }
    month_count 5
    total_count 12

    factory :sent_count_list do
      association :countable, factory: :list
    end

    factory :sent_count_organization do
      association :countable, factory: :organization
    end

  end

end
