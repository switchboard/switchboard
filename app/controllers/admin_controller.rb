class AdminController < ApplicationController

  before_filter :require_admin

  helper 'admin'

  def add_member
    error_objs = []
    ps = params[:user]
    number = ps.delete('phone')
    ps[:password] = 'user!'
    ps[:password_confirmation] = 'user!'
    @list = List.find(ps.delete('list_id'))
    @phone = PhoneNumber.find_by_number(number) if !number.empty?
    if @phone.nil? or @phone.user.nil?
      @user = User.new(ps)
      if @user.save
        @phone = PhoneNumber.create(:number => number, :user => @user)
      else
        error_objs << @user
      end
    end
    if error_objs.empty? and @phone.save
      @list.add_phone_number(@phone)
      redirect_to :action => 'show_members', :controller => 'admin', :params => {:list_id => @list.id}
    else
      error_objs << @phone unless @phone.nil?
      # if this were ever able to be called as a regular POST and not an xhr request
      # then we'd want to use respond_to do |format| instead of this.
      render :update do |page|
        page.replace_html 'flash_messages_container', :partial => '/layouts/flash_errors', :locals => {:objects => error_objs}
        page.show 'flash_messages_container'
      end
    end
  end

  def remove_member
    @list = List.find(params[:list_id])
    number = PhoneNumber.find(params[:number_id])
    @list.remove_phone_number(number)
    render :update do |page|
      page.remove "member_#{number.id}"
    end
  end

  def remove_list
    list_id = params[:list_id]
    list = List.find(list_id)
    list.destroy
    render :update do |page|
      page.remove "list_#{list.id}"
    end
  end

  def compose_message
    @list = List.find(params[:list_id])
    render :update do |page|
      page.hide 'flash_messages_container'
      page.replace_html 'compose_message', :partial => '/admin/message_body'
      page.replace_html 'col3', :partial => '/admin/send_message_button', :locals => {:list_id => list.id}
    end
  end


  def send_message
    @list = List.find(params[:list_id])
    return unless request.xhr? and @list
    confirmed = true
    if confirmed
      @message = WebMessage.create(:to => params[:list_id], :from => 'Web', :body => params[:message_body], :list => @list)
      MessageState.find_by_name("incoming")
      if MessageState.find_by_name("incoming").add_message(@message)
        #redirect_to :action => 'compose_message', :controller => 'admin', :params => {:list_id => params[:list_id]} 
        #flash[:notice] = "Your message was sent."
        render :update do |page|
          flash[:notice] = "Your message was sent."
          page.redirect_to list_path(@list) 
          #page << self.jsnotify("Your message was sent.", "success")
          #page.replace_html 'new-message', :partial => 'lists/list_info'
          #page.replace_html 'recent-messages', :partial => 'messages/recent_messages'
        end
      else
        render :update do |page|
          page.replace_html 'flash_messages_container', :partial => '/layouts/flash_errors', :locals => {:objects => [@message]} 
          page.show 'flash_messages_container'
        end
      end
     #else 
     #  render :update do |page|
     #    page << " $j().toastmessage('showSuccessToast', \"Preview your message to make sure it is correct before clicking send.\");"
     #    page << "$('confirmed_send_message_button').show();"
     #  end
     end
  end
 
  def remove_send_button
    return unless request.xhr?
    render :update do |page|
      page.hide 'confirmed_send_message_button'
      page.replace_html 'message_preview', ''
    end
  end

  private
   def jsnotify(msg)
    js = <<HERE
$j().toastmessage('showToast', {
            text     : '#{msg}',
            sticky   : true,
            position : 'top-right',
            type     : 'success',
            closeText: '',
        });
HERE
    puts js
    return js
  end
 
end
