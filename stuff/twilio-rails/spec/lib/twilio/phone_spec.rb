require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe Twilio::Phone do
  before(:each) do
    @phone = Twilio::Phone.new
  end

  it "should have an accessible callStatus" do
    pending("Needs to be written")
    @phone.callStatus = :ringing
    @phone.callStatus.should == :ringing
    @phone.callStatus = :in_progress
    @phone.callStatus.should == :in_progress
  end
  it "should receive calls from Twilio"
  it "should make calls to Twilio"
  it "should be able to forward calls to voicemail"
  it "should be able to receive text messages"
  it "should be able to listen"
  it "should be able to send digits"
end
