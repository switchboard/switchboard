require File.join(File.dirname(__FILE__),'..','..','spec_helper')


############## Helper Functions ##############


def verb_params(verb)
  raise ArgumentError, "#{verb} is not a valid TwiML verb"  if not Twilio.constants.include?(verb.to_s.downcase.titlecase)
  verb_class = eval("Twilio::#{verb.to_s.downcase.titlecase}")
  if verb_class.body_required? or verb_class.body_optional?
    "String body for #{verb_class.verb_name}"
  else
    []
  end
end


############## Verb Shared Groups ##############

describe "a TwiML verb", :shared => true do
  before(:each) do
    @verb = described_class.new(verb_params(described_class.to_s.split(/::/)[-1]))
  end

  it "should produce valid XML"
end


describe "a TwiML verb with children", :shared => true do
  before(:each) do
    @verb.body = nil if @verb.body_optional?
  end

  it "should not require a body" do
    @verb.body_required?.should == false
  end

  it "should be invalid with no children" do
    pending("Need to implement TwiML validation") { not @verb.responds_to? "valid" }
  end if described_class.children_required?

  it "should be invalid with a body" do
    pending("Need to implement TwiML validation") { not @verb.responds_to? "valid" }
  end if described_class.children_required? or described_class.body_prohibited?

  it "should produce valid XML with no children" do
    @verb.should have(0).children
    @verb.to_xml.should eql("<#{@verb.verb_name}></#{@verb.verb_name}>")
  end

  it "should contain one child" do
    child = @verb.allowed_verbs[0]
    @verb.send(child.downcase.to_sym, *verb_params(child))

    @verb.should have(1).children
  end

  it "should produce valid XML with one child" do
    child = @verb.allowed_verbs[0]
    @verb.send(child.downcase.to_sym, *verb_params(child))

    @verb.to_xml.should eql("<#{@verb.verb_name}>#{@verb.children[0].to_xml}</#{@verb.verb_name}>")
  end

  it "should contain multiple children" do
    3.times do |i|
      child = @verb.allowed_verbs[i % @verb.allowed_verbs.length]
      @verb.send(child.downcase.to_sym, *verb_params(child))
    end

    @verb.should have(3).children
  end

  it "should produce valid XML with multiple children" do
    3.times do |i|
      child = @verb.allowed_verbs[i % @verb.allowed_verbs.length]
      @verb.send(child.downcase.to_sym, *verb_params(child))
    end

    @verb.to_xml.should eql("<#{@verb.verb_name}>#{@verb.children.collect{|a|a.to_xml}.join('')}</#{@verb.verb_name}>")
  end
end


describe "a TwiML verb with a body", :shared => true do
  it_should_behave_like "a TwiML verb with no children"
  it "should be invalid with no body" do
    pending("Need to implement TwiML validation") { not @verb.responds_to? "valid" }
  end if described_class.body_required?

  it "should produce valid XML with no body" do
    @verb.body = nil
    @verb.to_xml.should eql("<#{@verb.verb_name}></#{@verb.verb_name}>")
  end unless described_class.body_required?

  it "should produce valid XML with a body" do
    @verb.body = "Hello, I <3 Ruby!"
    @verb.to_xml.should eql("<#{@verb.verb_name}>#{@verb.body.to_xs}</#{@verb.verb_name}>")
  end
end


describe "a TwiML verb with attributes", :shared => true do
  it "should produce valid XML with no attributes"

  it "should produce valid XML with attributes"

  it "should have attributes"

  it "should be valid with attributes" do
    pending("Need to implement TwiML validation") { not @verb.responds_to? "valid" }
  end
end


describe "a TwiML verb with no attributes", :shared => true do
  it "should not have any attributes" do
    @verb.should have(0).attributes
  end

  it "should produce valid XML with no attributes"

  it "should be invalid with attributes" do
    pending("Need to implement TwiML validation") { not @verb.responds_to? "valid" }
  end
end


describe "a TwiML verb with no children", :shared => true do
  it "should be invalid with children" do
    pending("Need to implement TwiML validation") { not @verb.responds_to? "valid" }
  end if described_class.children_prohibited?

  it "should produce valid XML with no children" do
    @verb.to_xml.should eql("<#{@verb.verb_name}>#{@verb.body unless @verb.body_prohibited?}</#{@verb.verb_name}>")
  end
end


############## Verb Specs ##############


describe Twilio::Say do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Play do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Gather do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with children"
end

describe Twilio::Record do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with no children"
end

describe Twilio::Dial do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with children"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Redirect do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Pause do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with no children"
end

describe Twilio::Hangup do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with no attributes"
  it_should_behave_like "a TwiML verb with no children"
end

describe Twilio::Number do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with attributes"
  it_should_behave_like "a TwiML verb with a body"
end

describe Twilio::Response do
  it_should_behave_like "a TwiML verb"
  it_should_behave_like "a TwiML verb with no attributes"
  it_should_behave_like "a TwiML verb with children"
end
