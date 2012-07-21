class PhoneNumbersController < ApplicationController
  before_filter :require_admin
  layout 'admin'
  
  def new
    @user = User.new
  end

  def index
    @title = "List Membership"

    puts("in phone numbers index: list is: " + @list.name)
    if (@list)
      @members = @list.phone_numbers
      puts("got numbers from list w/ id: " + @list.id.to_s)
    else
      @members = PhoneNumber.scoped
    end
    
  end
  
  def create
    # not used yet
  end
  
  def show
    @user = @current_user
  end

  def edit
    @user = @current_user
  end
  
  def update
    @user = @current_user # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
      redirect_to account_url
    else
      render :action => :edit
    end
  end
end
