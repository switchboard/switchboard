module Twilio
  module Verb
    module ClassMethods
      def ClassMethods.extended(other)
        other.set_defaults
      end

      def set_defaults
        @attributes = []
        @allowed_verbs = []
        @policy = { :body => :optional, :children => :optional }
      end

      def allowed_verbs(*verbs)
        return @allowed_verbs if verbs == []

        verbs.each do |verb|
          @allowed_verbs << verb.to_s.capitalize
        end
        @allowed_verbs = @allowed_verbs.uniq
      end

      def attributes(*attrs)
        return @attributes if attrs == []

        @attributes = (@attributes + attrs).uniq
        attr_accessor(*@attributes)
        @attributes
      end

      def nesting(policy={})
        if policy == :prohibited
          @policy[:body] = policy
          @policy[:children] = policy
          return
        end

        case policy[:body]
          when :required, :optional
            @policy[:body] = policy[:body]
            class_eval "def body; @body ; end
            def body=(str); @body = str ; end"

          when :prohibited
            @policy[:body] = policy[:body]

          else
            raise ArgumentError, "Only :required, :optional, and :prohibited are allowed policies"
        end

        case policy[:children]
          when :required, :optional
            @policy[:children] = policy[:children]
            class_eval "def children ; @children ; end
            def children=(ary) ; @children = ary ; end"

          when :prohibited
            @policy[:children] = policy[:children]

          else
            raise ArgumentError, "Only :required, :optional, and :prohibited are allowed policies"
        end
      end

      def body_required? ; @policy[:body] == :required ; end
      def body_optional? ; @policy[:body] == :optional ; end
      def body_prohibited? ; @policy[:body] == :prohibited ; end

      def children_required? ; @policy[:children] == :required ; end
      def children_optional? ; @policy[:children] == :optional ; end
      def children_prohibited? ; @policy[:children] == :prohibited ; end

      def verb_name
        self.to_s.split(/::/)[-1]
      end
    end

    def allowed_verbs
      self.class.allowed_verbs
    end

    def attributes
      self.class.attributes
    end

    def allowed?(verb)
      self.class.allowed_verbs.nil? ? false : self.class.allowed_verbs.include?(verb.to_s.capitalize)
    end

    def body_required?        ; self.class.body_required?       ; end
    def body_optional?        ; self.class.body_optional?       ; end
    def body_prohibited?      ; self.class.body_prohibited?     ; end

    def children_required?    ; self.class.children_required?   ; end
    def children_optional?    ; self.class.children_optional?   ; end
    def children_prohibited?  ; self.class.children_prohibited? ; end

    def verb_name
      self.class.verb_name
    end

    def initialize(body = nil, params = {})
      @children = []
      if body.class == String
        @body = body
      else
        @body = nil
        params = body || {}
      end
      params.each do |k,v|
        if respond_to? k.to_s+"="
          send(k.to_s+"=",v)
        else
          raise ArgumentError, "Invalid parameter (#{k}) for verb (#{self.class})"
        end
      end
    end

    def to_xml(opts = {})
      require 'builder' unless defined?(Builder)
      opts[:builder]  ||= Builder::XmlMarkup.new(:indent => opts[:indent])

      b = opts[:builder]
      attrs = {}
      attributes.each {|a| attrs[a] = send(a) unless send(a).nil? } unless attributes.nil?

      if @children and @body.nil?
        b.__send__(verb_name, attrs) do
          @children.each {|e|e.to_xml( opts.merge(:skip_instruct => true) )}
        end
      elsif @body and @children == []
        b.__send__(verb_name, @body)
      else
        raise ArgumentError, "Cannot have children and a body at the same time"
      end
    end


    ##### Verb Convenience Methods #####
    def say(string_to_say, opts = {})
      return unless allowed? :say
      @children << Twilio::Say.new(string_to_say, opts)
      @children[-1]
    end

    def play(file_to_play, opts = {})
      return unless allowed? :play
      @children << Twilio::Play.new(file_to_play, opts)
      @children[-1]
    end

    def gather(opts = {})
      return unless allowed? :gather
      @children << Twilio::Gather.new(opts)
      @children[-1]
    end

    def record(opts = {})
      return unless allowed? :record
      @children << Twilio::Record.new(opts)
      @children[-1]
    end

    def dial(number = "", opts = {})
      return unless allowed? :dial
      @children << Twilio::Dial.new(number, opts)
      @children[-1]
    end

    def redirect(url, opts = {})
      return unless allowed? :redirect
      @children << Twilio::Redirect.new(url, opts)
      @children[-1]
    end

    def pause(opts = {})
      return unless allowed? :pause
      @children << Twilio::Pause.new(opts)
      @children[-1]
    end

    def hangup
      return unless allowed? :hangup
      @children << Twilio::Hangup.new
      @children[-1]
    end

    def number(number, opts = {})
      return unless allowed? :number
      @children << Twilio::Number.new(number, opts)
      @children[-1]
    end
  end

  class Say
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :voice, :language, :loop
    nesting :body => :required, :children => :prohibited
  end

  class Play
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :loop
    nesting :body => :required, :children => :prohibited
  end

  class Gather
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :action, :method, :timeout, :finishOnKey, :numDigits
    allowed_verbs :play, :say, :pause
    nesting :body => :prohibited, :children => :optional
  end

  class Record
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :action, :method, :timeout, :finishOnKey, :maxLength, :transcribe, :transcribeCallback
    nesting :prohibited
  end

  class Dial
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :action, :method, :timeout, :hangupOnStar, :timeLimit, :callerId
    allowed_verbs :number
    nesting :body => :optional, :children => :optional
  end

  class Redirect
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :method
    nesting :body => :required, :children => :prohibited
  end

  class Pause
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :length
    nesting :prohibited
  end

  class Hangup
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    nesting :prohibited
  end

  class Number
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    attributes :sendDigits, :url
    nesting :body => :required, :children => :prohibited
  end

  class Response
    extend Twilio::Verb::ClassMethods
    include Twilio::Verb
    allowed_verbs :say, :play, :gather, :record, :dial, :redirect, :pause, :hangup
    nesting :body => :prohibited, :children => :optional
  end

  module ControllerHooks
    def add_hook(hook, name, code)
      session[:twilio_hooks] ||= {}
      session[:twilio_hooks][hook] ||= {}
      session[:twilio_hooks][hook][name] = code
      return nil
    end

    def remove_hook(hook, name)
      session[:twilio_hooks] ||= {}
      session[:twilio_hooks][hook] ||= {}
      session[:twilio_hooks][hook].delete(name) if session[:twilio_hooks][hook][name]
      return nil
    end

    def run_hook(hook)
      session[:twilio_hooks] ||= {}
      session[:twilio_hooks][hook] ||= {}
      session[:twilio_hooks][hook].each{|name,code| 
        RAILS_DEFAULT_LOGGER.debug "Running hook '#{name}'"
        eval(code)
      }
      return nil
    end
  end
end
