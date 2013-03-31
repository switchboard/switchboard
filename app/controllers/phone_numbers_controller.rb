class PhoneNumbersController < ApplicationController
  before_filter :require_admin
  layout 'admin'
  
  def new
    @contact = Contact.new
  end

  def index
    @title = 'List Membership'
    if @list
      @phone_numbers = @list.phone_numbers
    else
      @phone_numbers = PhoneNumber
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
