class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  layout 'admin'

  def new
  end

  def index
    @messages = Message.paginate_by_list_id(@list.id, :page => params[:page], :per_page => 10)
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

end
