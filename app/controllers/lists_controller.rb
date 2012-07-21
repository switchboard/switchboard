class ListsController < ApplicationController
  before_filter :require_admin

  helper 'lists', 'admin'

  layout 'admin'

  def new
    @title = "Create List"
    @mylist = List.new
  end
 
  def import
    @title = "Import Contacts"
  end
 
  def create
    @title = "Create List"
    @list = List.create(params[:list])
    if @list.save
      flash[:message] = "Your list has been created!"
      redirect_to list_url(@list)
    else
      flash[:notice] = "There was a problem creating your list. Please try another list name."
      redirect_to :action => 'new'
    end
  end
  
  def show
  end

  def edit
    @title = "Configure List"
    puts "flash is: " + flash.to_s
    puts "flash[:notice] is: " + flash[:notice].to_s
  end

  def index
    puts("in lists index")
    @lists = List.scoped
  end
  
  def update
    @list.update_attributes(params[:list])
    flash[:success] = "Your list configuration was updated."
    redirect_to :action => 'edit'
  end

  def upload_csv
    return unless @list
    @csv = Attachment.new(params[:members_csv])
    if @csv.save!
      results = @list.import_from_attachment(@csv.id)
      @errors = results[:errors]
      @successes = results[:successes]
      if @errors.length == 0
        flash[:success] = "All #{@successes} contacts successfully added!"
        redirect_to list_phone_numbers_url(@list) 
      end
    end
  end

  def check_name_available
    return unless request.xhr?
    if params[:name] =~ /\s+/
      avail = "List name cannot contain spaces!"
    else
      avail = List.find_by_name(params[:name]) ? "Not Available." : "Available!"
    end
    #render :update do |page|
    #  page.replace_html "availability", avail
    #end
    render :js => "alert('hi')"
  end

  def toggle_admin
    return unless request.xhr?
    number = PhoneNumber.find(params[:list_member_id])
    @list.toggle_admin(number)
    render :nothing => true
  end

  private

end
