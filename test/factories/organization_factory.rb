FactoryGirl.define do
  factory :organization do
    sequence(:name) {|n| "My Organization ##{n}"}
  end

end
