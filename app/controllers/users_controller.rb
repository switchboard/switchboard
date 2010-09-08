class UsersController < ApplicationController
#  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]
  layout 'admin'
  
  def new
    @user = User.new
  end

  def index
  end
  
  def create
    phone_number = PhoneNumber.create!(:number => params[:user].delete('phone_number'))
    params[:user].merge!({:password => 'inactive', :password_confirmation => 'inactive'})
    @user = User.create!(params[:user])
    @user.phone_numbers << phone_number
    reparams = Hash.new
    if @list
      @list.add_phone_number phone_number
      reparams = {:list_id => @list.id}
    end 
    redirect_to :action => 'new', :params => reparams
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
