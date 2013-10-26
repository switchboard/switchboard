class Admin::OrganizationsController < AdminController

  def index
    @organizations = Organization.order(:name)
  end

  def show
    @organization = Organization.find(params[:id])
    @lists = @organization.lists.order(:name)
  end

  def edit
    @organization = Organization.find(params[:id])
  end

  def update
    @organization = Organization.find(params[:id])
    if @organization.update_attributes(params[:organization])
      redirect_to admin_organization_path(@organization), notice: "The organization #{@organization.name} was updated."
    else
      render :edit
    end
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(params[:organization])
    if @organization.save
      redirect_to admin_organization_path(@organization), notice: "The organization #{@organization.name} was created."
    else
      flash.now.alert = "Organization could not be saved"
      render :new
    end
  end

end