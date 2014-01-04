FactoryGirl.define do
  factory :phone_number do
    sequence(:number) {|n| "204237789#{n}"}
    contact
  end

end
