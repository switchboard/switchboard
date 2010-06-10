class EmailMessage < Message

  def self.create_from_params(params)
    msg = {}
    msg[:body] = params['Body']
    msg[:from] = params['From']
    msg[:to] = params['To']
    ### these need attributes
    #msg[:sms_sid] = params['SmsSid']
    #msg[:account_sid] = params['AccountSid']
    EmailMessage.create!(msg)
  end

  def default_list
    breakpoint
    tokens = self.to.split(/@/)
    return tokens[0]
  end

  def number
    tokens = self.from.split(/@/)
    return tokens[0]
  end

  def carrier
    tokens = self.from.split(/@/)
    return tokens[1]
  end

end
