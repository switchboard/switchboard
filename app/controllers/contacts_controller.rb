class ContactsController < ApplicationController

  def new
    @title = "Add Contact"
    @contact = Contact.new
    @contact.phone_numbers.build
  end

  def index
  end

  # Not ideal, but works until we combine Contact and PhoneNumber
  def create
    @number = params[:contact][:phone_numbers_attributes]['0'][:number].try(:gsub, /[^0-9]/, '')
    if @phone_number = PhoneNumber.find_by_number(@number)
      @contact = @phone_number.contact
      @success = @contact.update_attributes(params[:contact].slice(:first_name, :last_name))
    else
      @contact = Contact.new(params[:contact].slice(:first_name, :last_name))
      @success = @contact.save && @contact.phone_numbers.create(number: @number).valid?
    end

    if @success
      if @list
        @list.list_memberships.create(:phone_number_id => @contact.phone_numbers.first.id)
        redirect_path = list_path(@list)
      else
        redirect_path = lists_path
      end
      redirect_to redirect_path, notice: "The contact #{@contact.full_name} was added."
    else
      flash[:error] = 'There was a problem saving that contact.'
      render :new
    end
  end

  def edit
    @contact = Contact.find(params[:id])
  end

  def update
    @contact = Contact.find(params[:id])
    if @contact.update_attributes(params[:contact])
      redirect_path = @list ? list_phone_numbers_path(@list) : lists_path
      redirect_to redirect_path, notice: 'Contact information updated.'
    else
      flash[:error] = 'There was a problem saving that contact.'
      render action: :edit
    end
  end
end
