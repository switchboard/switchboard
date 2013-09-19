class AdminController < ApplicationController

  before_filter :require_admin

  helper 'administration'

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
    @number = PhoneNumber.find(params[:number_id])
    @list.remove_phone_number(@number)
  end

  def remove_list
    @list = List.find(params[:list_id])
    @list.destroy
  end

  def compose_message
    @list = List.find(params[:list_id])
    render :update do |page|
      page.hide 'flash_messages_container'
      page.replace_html 'compose_message', :partial => '/admin/message_body'
      page.replace_html 'col3', :partial => '/admin/send_message_button', :locals => {:list_id => list.id}
    end
  end


  def remove_send_button
    return unless request.xhr?
    render :update do |page|
      page.hide 'confirmed_send_message_button'
      page.replace_html 'message_preview', ''
    end
  end

  def check_list_availability
    list_name = params[:name].upcase
    avail = false
    if params[:name] =~ /\s+/
      msg = "List name cannot contain spaces."
    else
      avail = List.find_by_name(list_name) ? false : true
      msg = avail ? "That list name is available." : "That name is not available -- try another."
    end
    #render :update do |page|
    #  page.replace_html "availability", avail
    #end
    render :json => { message: msg, available: avail }
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
