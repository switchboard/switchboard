class PhoneNumbersController < ApplicationController

  def new
    @contact = Contact.new
  end

  def index
    if @list
      @title = 'List Membership'
      @phone_numbers = @list.phone_numbers
    else
      @title = "Members for all your organization's lists"
      @phone_numbers = PhoneNumber.joins(:lists => :organization).where('organizations.id' => current_organization.id)
    end
    @phone_numbers = @phone_numbers.order('updated_at desc').page(params[:page]).per(13)
  end

  def create
    # not used yet
  end

  def show
    @contact = @current_user
  end

  def edit
    @contact = @current_user
  end

  def destroy
    @number = PhoneNumber.find(params[:id])
    @list.remove_phone_number(@number)
  end

  def update
    @contact = @current_user # makes our views "cleaner" and more consistent
    if @contact.update_attributes(params[:contact])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end