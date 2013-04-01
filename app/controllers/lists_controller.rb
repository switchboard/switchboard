class ListsController < AdminController

  def new
    @title = "Create List"
    @new_list = current_organization.lists.build
  end

  def create
    @title = "Create List"
    @new_list = current_organization.lists.build(params[:list])
    if @new_list.save
      redirect_to list_url(@new_list), notice: 'Your list has been created!'
    else
      flash.now[:notice] = "There was a problem creating your list."
      render :new
    end
  end

  def show
  end

  def edit
    @title = "Configure List"
  end

  def index
    @lists = current_organization.lists.order(:name)
  end


  def destroy
    @list.destroy
    redirect_to lists_path, notice: "The list #{@list.name} was deleted."
  end

  def update
    if @list.update_attributes(params[:list])
      redirect_to list_path(@list), notice: 'Your list configuration was updated.'
    else
      render :edit
    end
  end

  def import
    @title = "Import Contacts"
  end

  def upload_csv
    if @list.update_attributes(params[:list])
      results = @list.import_from_attachment
      @errors = results[:errors]
      @success_count = results[:success_count]
      if @errors.empty?
        flash[:notice] = "All #{@successes} contacts successfully added!"
        redirect_to list_phone_numbers_path(@list)
      else
        render :import
      end
    end
  end

  def check_name_available
    return unless request.xhr?
    if params[:name] =~ /\s+/
      avail_message = "List name cannot contain spaces!"
    else
      avail_message = List.find_by_name(params[:name].upcase) ? "That name is already being used." : ''
    end
    render text: avail_message
  end

  def toggle_admin
    return unless request.xhr?
    number = PhoneNumber.find(params[:list_member_id])
    @list.toggle_admin(number)
    render :nothing => true
  end

  private

end
