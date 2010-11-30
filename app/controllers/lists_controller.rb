class ListsController < ApplicationController
  before_filter :require_admin

  helper 'lists', 'admin'

  layout 'admin'

  def new
  end
  
  def create
    @list = List.create(params[:list])
    if @list.save
      flash[:message] = "Your list has been created!"
      redirect_to :action => 'show', :params => {:list_id => @list.id}
    else
      flash[:notice] = "There was a problem creating your list. Please try another list name."
      redirect_to :action => 'new'
    end
  end
  
  def show
  end

  def edit
  end
  
  def update
    @list.update_attributes(params[:list])
    redirect_to :action => 'edit'
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

  def toggle_admin
    return unless request.xhr?
    number = PhoneNumber.find(params[:list_member_id])
    @list.toggle_admin(number)
    render :nothing => true
  end

  private

end
