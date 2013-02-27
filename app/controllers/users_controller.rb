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
    input_number_string = params[:user].delete('phone_number')

    number_string = input_number_string.gsub(/\D/, '')
    phone_number = PhoneNumber.find_or_create_by_number(:number => number_string)

    @user = User.new(params[:user])

    @user.password = 'inactive'
    @user.password_confirmation = 'inactive'

    @user.phone_numbers << phone_number

    @user.save!

    if @list
      @list.add_phone_number phone_number
      redirect_to list_path(@list)
    else
      redirect_to lists_path
    end
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
