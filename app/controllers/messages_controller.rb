class MessagesController < ApplicationController
  before_filter :require_admin, :only => [:new, :index]

  helper 'administration'

  skip_before_filter :verify_authenticity_token
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

  def send_message
    @list = List.find(params[:list_id])
    confirmed = true
    if confirmed
      @message = WebMessage.new(:from => 'Web', :body => params[:message_body])
      @message.to = @list.id
      @message.list = @list
      @message.save!

      respond_to do |format|
        format.html do
          if MessageState.find_by_name("incoming").add_message(@message)
            flash[:notice] = "Message sent"
          else
            flash[:alert] = "Error sending message"
          end
        end

        redirect_to list_url(@list)
      end
    #else
    #  render :update do |page|
    #    page << " $j().toastmessage('showSuccessToast', \"Preview your message to make sure it is correct before clicking send.\");"
    #    page << "$('confirmed_send_message_button').show();"
    #  end
    end
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
