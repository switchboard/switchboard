FactoryGirl.define do
  factory :contact do
    sequence(:email) {|n| "user-#{n}@test.com"}
    sequence(:first_name) {|n| "Bob ##{n}"}
    sequence(:last_name) {|n| "Smith ##{n}"}

    trait :with_phone_number do
      after(:create) do |contact, evaluator|
        FactoryGirl.create(:phone_number, contact: contact)
      end
    end

  end

end
