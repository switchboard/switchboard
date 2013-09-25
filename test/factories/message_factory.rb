FactoryGirl.define do

  factory :message do
    sequence(:body) {|n| "This is the body of a message"}
  end

end
