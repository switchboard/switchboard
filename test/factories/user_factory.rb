FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user-#{n}@test.com"}
    sequence(:first_name) {|n| "Bob ##{n}"}
    sequence(:last_name) {|n| "Smith ##{n}"}

    trait :with_phone_number do
      after(:create) do |user, evaluator|
        FactoryGirl.create(:phone_number, user: user)
      end
    end

  end

end
