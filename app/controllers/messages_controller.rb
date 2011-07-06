class MessagesController < ApplicationController
  before_filter :require_admin

  helper 'admin'

#  skip_before_filter :verify_authenticity_token
#  before_filter :authenticate, :only => [:create]
  layout 'admin'

  def new
  end

  def index
  end 

  def create 
    # assignment of @message assumed in subclasses
    queue_message if @message
  end

  protected

  def queue_message
    incoming = MessageState.find_or_create_by_name("incoming")
    incoming.messages << @message
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username,password|
      username=='username' and password=='password'
    end
  end

end
