class ListsController < ApplicationController
  before_filter :require_admin
  before_filter :get_list, :except => [:new, :create] 

  helper 'lists'

  def new
  end
  
  def create
    # not used yet
  end
  
  def show
  end

  def edit
    if !@list.nil?
      if request.xhr?
        render :update do |page|
          page.replace_html 'col2', :partial => 'lists/edit'
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
      render :action => :edit
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
