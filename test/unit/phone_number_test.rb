require 'test_helper'

class PhoneNumberTest < ActiveSupport::TestCase
  
  test 'formats number on assignment' do
    phone = PhoneNumber.new(number: '(215) 222-2222')
    assert phone.number == '2152222222'
  end

end