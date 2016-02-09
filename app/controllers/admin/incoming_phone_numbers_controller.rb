class Admin::IncomingPhoneNumbersController < AdminController

  def index
    IncomingPhoneNumber.fetch_from_stripe
    @numbers = IncomingPhoneNumber.order(:phone_number)
  end

  def edit
    @number = IncomingPhoneNumber.find(params[:id])
  end

  def update
    @number = IncomingPhoneNumber.find(params[:id])
    if @number.update_attributes(numbers_params)
      redirect_to admin_numbers_path, notice: "The details were updated for phone number #{format_phone @number.phone_number}."
    else
      flash.now[:alert] = 'The phone number could not be updated.'
      render :edit
    end
  end

  def unassign
    @number = IncomingPhoneNumber.find(params[:id])
    @list = @number.list
    @list.update_column(:incoming_phone_number_id, nil)
    redirect_to admin_numbers_path, notice: "The phone number #{format_phone @number.phone_number} was unlinked from the list #{@list.try(:name)}."
  end

  private

  def numbers_params
    params.require(:incoming_phone_number).permit(:notes, :list_id)
  end

end