FactoryGirl.define do

  factory :list do
    organization
    sequence(:name) {|n| "list_##{n}"}
    sequence(:long_name) {|n| "My List ##{n}"}
    sequence(:incoming_number) {|n| (100_000_0000 + n).to_s}
    use_incoming_keyword false
    open_membership true
    moderated_membership false
    use_welcome_message false
    custom_welcome_message 'Welcome to your test list'
  end

end
