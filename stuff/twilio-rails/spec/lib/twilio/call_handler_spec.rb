require File.join(File.dirname(__FILE__),'..','..','spec_helper')

describe Twilio::CallHandler do
  before(:each) do
    puts "Running before each Twilio::CallHandler"
    @phone = mock('Twilio::Phone')
    @call_handler = Twilio::CallHandler.new :phone => @phone
  mock
  end

  it "should complain on invalid TwiML"
  it "should validate incoming TwiML"

  describe "when receiving an incoming call" do
    it "should request TwiML for incoming calls"
    it "should answer incoming calls" do
      @phone.should_receive('callStatus=').once.with(an_instance_of(Symbol)) unless @phone.respond_to? 'callStatus='
      @phone.stub('callStatus').and_return(:ringing) unless @phone.respond_to? :callStatus
      @call_handler.answer(@phone)
    end
    it "should provide valid call data for incoming calls"
  end

  describe "when making an outgoing call" do
    it "should make outgoing calls"
    it "should request TwimL when outgoing call is answered"
    it "should provide valid call data for outgoing calls"
  end

  describe "when processing a Response verb" do
    it "should not do anything"
  end


  describe "when processing a Say verb" do
    it "should talk" do
      @phone.should_receive(:enqueue).with("Testing String")
      response = Twilio::Response.new
      response.say "Testing String"
      @call_handler.process(response)
    end

    it "should repeat on loop" do
      @phone.should_receive(:enqueue).with("Testing String").exactly(3).times
      response = Twilio::Response.new
      response.say "Testing String", :loop => 3
      @call_handler.process(response)
    end
  end

  describe "when processing a Play verb" do
    it "should stream audio file" do
      @phone.should_receive(:enqueue).with("Audio File Data")
      response = Twilio::Response.new
      response.play "Audio File Data"
      @call_handler.process(response)
    end

    it "should repeat stream on loop" do
      @phone.should_receive(:enqueue).with("Audio File Data").exactly(3).times
      response = Twilio::Response.new
      response.play "Audio File Data", :loop => 3
      @call_handler.process(response)
    end
  end

  describe "when processing a Gather verb" do
    it "should talk" do
      @phone.should_receive(:enqueue).with("Begin listening for input")
      @phone.should_receive(:enqueue).with("Testing String")
      response = Twilio::Response.new
      response.gather.say "Testing String"
      @call_handler.process(response)
      @call_handler.instance_eval("@input_status").should == :gather
    end
    it "should play"
    it "should listen"
    it "should timeout"
    it "should accept 1 digits"
    it "should accept multiple digits"
    it "should accept digits until (star)"
    it "should send digits to application"
  end

  describe "when processing a Record verb" do
    it "should listen on Record"
    it "should timeout on Record"
    it "should Record until (star)"
    it "should transcribe recording"
    it "should submit transcription to application"
  end

  describe "when processing a Dial verb" do
    it "should make outgoing call on Dial"
    it "should connect phones on Dial"
    it "should make outgoing call to Number on Dial"
    it "should timeout on Dial"
    it "should hangup call on (star) when Dial-ing"
  end

  describe "when processing a Redirect verb" do
    it "should call application on Redirect"
  end

  describe "when processing a Pause verb" do
    it "should pause on Pause"
  end

  describe "when processing a Hangup verb" do
    it "should disconnect phone on Hangup"
    it "should notify application on Hangup"
  end

end
