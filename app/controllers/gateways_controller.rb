class GatewaysController < ApplicationController
  # GET /gateways
  # GET /gateways.json
  def index
    @gateways = Gateway.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gateways }
    end
  end

  # GET /gateways/1
  # GET /gateways/1.json
  def show
    @gateway = Gateway.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gateway }
    end
  end

  # GET /gateways/new
  # GET /gateways/new.json
  def new
    @gateway = Gateway.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gateway }
    end
  end

  # GET /gateways/1/edit
  def edit
    @gateway = Gateway.find(params[:id])
  end

  # POST /gateways
  # POST /gateways.json
  def create
    @gateway = Gateway.new(params[:gateway])

    respond_to do |format|
      if @gateway.save
        format.html { redirect_to @gateway, notice: 'Gateway was successfully created.' }
        format.json { render json: @gateway, status: :created, location: @gateway }
      else
        format.html { render action: "new" }
        format.json { render json: @gateway.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gateways/1
  # PUT /gateways/1.json
  def update
    @gateway = Gateway.find(params[:id])

    respond_to do |format|
      if @gateway.update_attributes(params[:gateway])
        format.html { redirect_to @gateway, notice: 'Gateway was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gateway.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gateways/1
  # DELETE /gateways/1.json
  def destroy
    @gateway = Gateway.find(params[:id])
    @gateway.destroy

    respond_to do |format|
      format.html { redirect_to gateways_url }
      format.json { head :no_content }
    end
  end
end
