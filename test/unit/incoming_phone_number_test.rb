require 'test_helper'

class IncomingPhoneNumbersTest < ActiveSupport::TestCase

  test 'fetches incoming numbers from Twilio' do

    Settings.twilio.sid = 'ACb239e54c0b608dc8431b4c2acadd6cc8'
    Settings.twilio.token = '5deeaae84db9956877b90a99fb641750'

    VCR.use_cassette('IncomingPhoneNumbersTest.fetch_numbers') do

      assert_difference('IncomingPhoneNumber.count', 1) do
        IncomingPhoneNumber.fetch_from_twilio
      end

      incoming_number = IncomingPhoneNumber.find_by_sid('PN476c9bc2c86815cba0cc73ac6011abfb')
      assert incoming_number
      assert incoming_number.phone_number == '+12155158845'
      assert incoming_number.created_at == DateTime.new(2016,2,5,0,57,28)
    end

  end

end
