#!/usr/bin/env ruby

require 'twiliolib'

# Twilio REST API version
API_VERSION = '2008-08-01'

# Twilio AccountSid and AuthToken
ACCOUNT_SID = 'AC8320a2e64a184dd450a41a8533020e81'
ACCOUNT_TOKEN = '42dac91b4dba8a556f7049bf022809e2'

# Outgoing Caller ID previously validated with Twilio
CALLER_ID = '2679777848';

# Create a Twilio REST account object using your Twilio account ID and token
account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)

d = {
    'To' => CALLER_ID,
    'From' => '215-346-6997',
    'Body' => 'hello cruel sms world!'
}
resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
    'POST', d)
resp.error! unless resp.kind_of? Net::HTTPSuccess
puts "code: %s\nbody: %s" % [resp.code, resp.body]


