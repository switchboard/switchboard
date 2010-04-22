class TwilioMessage < Message

  def self.create_from_params(params)
    msg = {}
    msg[:body] = params['Body']
    msg[:from] = params['From']
    msg[:to] = params['To']
    ### these need attributes
    #msg[:sms_sid] = params['SmsSid']
    #msg[:account_sid] = params['AccountSid']
    TwilioMessage.create!(msg)
  end

end
