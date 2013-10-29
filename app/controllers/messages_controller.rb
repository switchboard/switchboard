class MessagesController < ApplicationController
  before_filter :require_user, :only => [:new, :index, :send_message]
  skip_before_filter :verify_authenticity_token

  def new
    @message = WebMessage.new
  end

  def index
    if @list
      @messages = @list.messages.for_display.page(params[:page]).per(20)
    else
      @messages = Message.joins(:list).where('lists.organization_id = ?', current_organization.id).for_display.recent.limit(40)
    end
  end

  def create
    # assignment of @message assumed in subclasses
    queue_message if @message
  end

  def send_message
    confirmed = true
    if confirmed
      @message = WebMessage.new(:from => 'Web', :body => params[:web_message][:body])
      # Not setting 'to' to list_id
      # @message.to = @list.id
      @message.list = @list
      if ( @message.save )
        flash[:notice] = "Message sent."
        redirect_to list_url(@list)
      else
        flash[:alert] = "Could not send message: " + @message.errors.full_messages[0]
        render 'new'
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
    ## This is no longer necessary; messages are by default incoming
    ## Leaving this because we may want to add processing job here

    # incoming = MessageState.find_or_create_by_name("incoming")
    # incoming.messages << @message
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username,password|
      username=='username' and password=='password'
    end
  end

end
