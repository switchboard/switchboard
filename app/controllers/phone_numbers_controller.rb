class PhoneNumbersController < ApplicationController
  before_filter :require_admin
  layout 'admin'
  
  def new
    @user = User.new
  end

  def index
    @title = 'List Membership'
    if @list
      @phone_numbers = @list.phone_numbers
    else
      @phone_numbers = PhoneNumber
    end
    @phone_numbers = @phone_numbers.order('updated_at desc').page(params[:page]).per(14)
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
