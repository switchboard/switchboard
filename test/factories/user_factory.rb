FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user-#{n}@test.com"}
    sequence(:name) {|n| "Alice ##{n}"}
    password 'password'
    password_confirmation 'password'

    trait :with_organization do
      after(:create) do |user, evaluator|
        org = FactoryGirl.create(:organization)
        user.organizations << org
      end
    end

  end

end
