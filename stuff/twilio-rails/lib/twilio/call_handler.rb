module Twilio
  class CallHandler
    attr_accessor :callStatus

    def initialize(opts = {})
      if opts[:phone]
        @phone = opts[:phone]
      else
        @phone = Twilio::Phone.new
      end

      @input_status = :none
    end

    def answer(phone)
      @phone = phone
      @phone.callStatus = :in_progress
    end

    def process(xml_or_verb_root)
      if xml_or_verb_root.class == String
        root = Twilio::Verb.parse(xml_or_verb_root)
      elsif xml_or_verb_root.class.include? Twilio::Verb
        root = xml_or_verb_root
      else
        raise ArgumentError, "Invalid input; not a Verb or String (#{xml_or_verb_root.inspect})"
      end

      case root
        when Response
          root.children.each{|child| process(child) }
        when Say
          (root.loop||1).times do
            @phone.enqueue root.body
          end
        when Play
          (root.loop||1).times do
            @phone.enqueue root.body
          end
        when Gather
          @phone.enqueue "Begin listening for input"
          @input_status = :gather
          root.children.each{|child| process(child) }
        when Record
        when Dial
        when Number
        when Redirect
        when Pause
        when Hangup
        else
      end
    end
  end
end
