require 'ostruct'
class PhoneNumbersController < ApplicationController

  def new
    @contact = Contact.new
  end

  def index
    if @list
      @title = 'List Members'
      @phone_numbers = @list.phone_numbers
      @search_form = OpenStruct.new(params.slice(:q))
      if @search_form.q.present?
        escaped_search = @search_form.q.gsub('%', '\%').gsub('_', '\_')
        if @search_form.q =~ /\d{2}/
          escaped_search.gsub!(/[^0-9]/, '')
          @phone_numbers = @phone_numbers.where('number LIKE ?', "%#{escaped_search}%" )
        else
          @phone_numbers = @phone_numbers.joins(:contact).where('contacts.full_name LIKE ?', "%#{escaped_search}%")
        end
      end
    else
      @title = "Members for all your organization's lists"
      @phone_numbers = PhoneNumber.joins(:lists => :organization).where('organizations.id' => current_organization.id)
    end
    @phone_numbers = @phone_numbers.order('updated_at desc').page(params[:page]).per(13)

    render partial: 'member_list', layout: false if request.xhr?
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
    respond_to do |format|
      format.html do
        redirect_to @list, notice: "Contact #{@number.name_and_number} removed from list."
      end
    end
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