class FakePhoneMessage < Message

  def self.create_from_params(params)
    ## params from fake phone should match attributes directly
    FakePhoneMessage.create!(params)
  end

end
