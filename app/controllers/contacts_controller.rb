class ContactsController < AdminController

  def new
    @title = "Add Contact"
    @contact = Contact.new
    @contact.phone_numbers.build
  end

  def index
  end

  def create
    @contact = Contact.new(params[:contact])

    if @contact.save
      if @list
        @list.add_phone_number(@contact.phone_numbers.first)
        redirect_path = list_path(@list)
      else
        redirect_path = lists_path
      end
      redirect_to redirect_path, notice: "The contact #{@contact.full_name} was added."
    else
      logger.info @contact.errors.inspect
      flash[:error] = 'There was a problem saving that contact.'
      render :new
    end
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    @contact = Contact.find(params[:id]) # makes our views "cleaner" and more consistent
    if @contact.update_attributes(params[:contact])
      redirect_path = @list ? list_phone_numbers_path(@list) : lists_path
      redirect_to redirect_path, notice: 'Contact information updated.'
    else
      flash[:error] = 'There was a problem saving that contact.'
      render action: :edit
    end
  end
end
