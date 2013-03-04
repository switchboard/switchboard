class UsersController < ApplicationController
#  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_admin
  layout 'admin'

  def new
    @title = "Add Contact"
    @user = User.new
    @user.phone_numbers.build
  end

  def index
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      if @list
        @list.add_phone_number(@user.phone_numbers.first)
        redirect_path = list_path(@list)
      else
        redirect_path = lists_path
      end
      redirect_to redirect_path, notice: "The user #{@user.full_name} was added."
    else
      logger.info @user.errors.inspect
      flash[:error] = 'There was a problem saving that user.'
      render :new
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
      redirect_path = @list ? list_phone_numbers_path(@list) : lists_path
      redirect_to redirect_path, notice: 'User information updated.'
    else
      flash[:error] = 'There was a problem saving that user.'
      render action: :edit
    end
  end
end
