class ListsController < ApplicationController
  before_filter :require_admin
  before_filter :get_list, :except => [:new, :create, :check_name_available] 

  helper 'lists', 'admin'

  layout 'admin'

  def new
  end
  
  def create
    @list = List.create(params[:list])
    if @list.save
      flash[:message] = "Your list has been created!"
      redirect_to :controller => 'admin', :action => 'manage', :params => {:selected_list => @list.id}
    else
      flash[:notice] = "There was a problem creating your list. Please try another list name."
      redirect_to :action => 'new'
    end
  end
  
  def show
  end

  def edit
    if !@list.nil?
      if request.xhr?
        render :update do |page|
          page.replace_html 'edit_list', :partial => 'lists/edit'
          page.hide 'flash_messages_container'
        end
      end
   end  
  end
  
  def update
    if @list.update_attributes(params[:list])
       render :update do |page|
         page.replace_html "flash_messages_container", "The list has been updated!"
         page.show "flash_messages_container"
       end
    else
      render :update do |page|
        page.replace_html 'flash_messages_container', :partial => '/layouts/flash_errors', :locals => {:objects => [@list]} 
        page.show "flash_messages_container"    
      end
    end
  end

  def messages
    @messages = Message.paginate_by_list_id(@list.id, :page => params[:page], :per_page => 10)
    if request.xhr?
      render :update do |page|
        page.replace_html "message_list", :partial => 'lists/message', :collection => @messages
        page.replace_html 'pagination', :partial => 'lists/message_pagination_links'
      end
    end
  end

  def check_name_available
    if params[:name] =~ /\s+/
      avail = "List name cannot contain spaces!"
    else
      avail = List.find_by_name(params[:name]) ? "Not Available." : "Available!"
    end
    render :update do |page|
      page.replace_html "availability", avail
    end
  end

  private
    def get_list
      @list = List.find(params[:list_id])
      if @list.nil?
        flash[:notice] = "No list selected"
        if request.xhr?
           render :update do |page|
             page.replace_html 'flash_messages_container', flash[:notice] 
             page.show 'flash_messages_container'
           end
        else
          redirect_to :controller => 'admin', :action => 'manage'
        end
      end
    end

end
