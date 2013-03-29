class TwilioMessage < Message

  attr_accessible :body, :from, :to, as: :system

  def self.create_from_params(params)
    TwilioMessage.create!({body: params['Body'], from: params['From'], to: params['To']}, as: :system)
  end

end
