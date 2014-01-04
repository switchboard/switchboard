require 'test_helper'

class PhoneNumberTest < ActiveSupport::TestCase

  test 'formats number on assignment' do
    phone = PhoneNumber.new(number: '(215) 222-2222')
    assert phone.number == '2152222222'
  end

  test 'validates valid US phone numbers' do
    assert ! PhoneNumber.new(number: '(295) 204-1945').valid?
    assert ! PhoneNumber.new(number: '(911) 204-1945').valid?
    assert ! PhoneNumber.new(number: '(215) 123-1945').valid?
  end
end