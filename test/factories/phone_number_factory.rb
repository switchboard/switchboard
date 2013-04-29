FactoryGirl.define do
  factory :phone_number do
    sequence(:number) {|n| "123123789#{n}"}
    contact
  end

end
