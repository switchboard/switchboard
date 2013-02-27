class ServicePhoneNumbersController < ApplicationController
  # GET /service_phone_numbers
  # GET /service_phone_numbers.json
  def index
    @service_phone_numbers = ServicePhoneNumber.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @service_phone_numbers }
    end
  end

  # GET /service_phone_numbers/1
  # GET /service_phone_numbers/1.json
  def show
    @service_phone_number = ServicePhoneNumber.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @service_phone_number }
    end
  end

  # GET /service_phone_numbers/new
  # GET /service_phone_numbers/new.json
  def new
    @service_phone_number = ServicePhoneNumber.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @service_phone_number }
    end
  end

  # GET /service_phone_numbers/1/edit
  def edit
    @service_phone_number = ServicePhoneNumber.find(params[:id])
  end

  # POST /service_phone_numbers
  # POST /service_phone_numbers.json
  def create
    @service_phone_number = ServicePhoneNumber.new(params[:service_phone_number])

    respond_to do |format|
      if @service_phone_number.save
        format.html { redirect_to @service_phone_number, notice: 'Service phone number was successfully created.' }
        format.json { render json: @service_phone_number, status: :created, location: @service_phone_number }
      else
        format.html { render action: "new" }
        format.json { render json: @service_phone_number.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /service_phone_numbers/1
  # PUT /service_phone_numbers/1.json
  def update
    @service_phone_number = ServicePhoneNumber.find(params[:id])

    respond_to do |format|
      if @service_phone_number.update_attributes(params[:service_phone_number])
        format.html { redirect_to @service_phone_number, notice: 'Service phone number was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @service_phone_number.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /service_phone_numbers/1
  # DELETE /service_phone_numbers/1.json
  def destroy
    @service_phone_number = ServicePhoneNumber.find(params[:id])
    @service_phone_number.destroy

    respond_to do |format|
      format.html { redirect_to service_phone_numbers_url }
      format.json { head :no_content }
    end
  end
end
