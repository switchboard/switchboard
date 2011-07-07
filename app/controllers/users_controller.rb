class UsersController < ApplicationController
#  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_admin
  layout 'admin'
  
  def new
    @title = "Add Contact"
    @user = User.new
  end

  def index
  end
  
  def create
    phone_number = PhoneNumber.find_or_create_by_number(:number => params[:user].delete('phone_number'))
    params[:user].merge!({:password => 'inactive', :password_confirmation => 'inactive'})
    @user = User.create!(params[:user])
    @user.phone_numbers << phone_number
    reparams = Hash.new
    if @list
      @list.add_phone_number phone_number
      reparams = {:list_id => @list.id}
    end 
    redirect_to list_path(@list_id)
  end
  
  def show
    @title = "Show Contact"
    @user = User.find(params[:id]) 
  end

  def edit
    @title = "Edit Contact"
    @user = User.find(params[:id])
  end
 
  def import
    
  end
 
  def update
    @user = User.find(params[:id]) # makes our views "cleaner" and more consistent
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated!"
    end
    render :action => :edit
  end
end
