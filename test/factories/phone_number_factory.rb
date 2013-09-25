FactoryGirl.define do

  factory :phone_number do
    contact
    sequence(:number) {|n| (555_555_0000 + n).to_s}
  end

end
