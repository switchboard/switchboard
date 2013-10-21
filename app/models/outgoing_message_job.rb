class OutgoingMessageJob
  @queue = :outgoing

  def self.perform(list_id, to, from, message_body, message_id = nil)
    if to.include?('@')
      send_email(to, body: message_body, from: from)
      # Not counting emails in list counts
      Message.increment_outgoing_count(message_id) if message_id
    else
      TwilioSender.send_sms(to, message_body, from)
      List.increment_outgoing_count(list_id)
      Message.increment_outgoing_count(message_id) if message_id
    end
  end

  # Needs work
  def self.send_email(to, opts = {})
    opts[:server]      ||= 'localhost'
    opts[:from]        ||= ''
    opts[:from_alias]  ||= 'Switchboard'
    opts[:subject]     ||= ""
    opts[:body]        ||= ""

    msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}

#{opts[:body]}
END_OF_MESSAGE

    Net::SMTP.start(opts[:server]) do |smtp|
      smtp.send_message(msg, opts[:from], to)
    end
  end

end