class SurveysController < ApplicationController
  before_filter :require_admin

  helper 'surveys', 'administration'

  layout 'admin'

  def new
    @title = "Create Survey"
  end
 
  def import
    @title = "Import Contacts"
  end
 
  def create
    @title = "Create Survey"
    @survey = Survey.create(params[:survey])
    if @survey.save
      flash[:message] = "Your survey has been created!"
      redirect_to :action => ''
    else
      flash[:notice] = "There was a problem creating your survey. Please try another survey name."
      redirect_to :action => 'new'
    end
  end
  
  def show
  	@survey = Survey.find(params[:id])
  end

  def edit
    @title = "Configure Survey"
    puts "flash is: " + flash.to_s
    puts "flash[:notice] is: " + flash[:notice].to_s
  end

  def index
    @surveys = Survey.scoped
  end
  
  def update
    @survey.update_attributes(params[:survey])
    flash[:notice] = "Your survey configuration was updated."
    redirect_to :action => 'edit'
  end

  def upload_csv
    return unless @survey
    @csv = Attachment.new(params[:members_csv])
    if @csv.save!
      results = @survey.import_from_attachment(@csv.id)
      @errors = results[:errors]
      @successes = results[:successes]
      if @errors.length == 0
        flash[:notice] = "All #{@successes} contacts successfully added!"
        redirect_to survey_phone_numbers_url(@survey) 
      end
    end
  end

  def check_name_available
    return unless request.xhr?
    if params[:name] =~ /\s+/
      avail = "Survey name cannot contain spaces!"
    else
      avail = Survey.find_by_name(params[:name]) ? "Not Available." : "Available!"
    end
    render :update do |page|
      page.replace_html "availability", avail
    end
  end

  def toggle_admin
    return unless request.xhr?
    number = PhoneNumber.find(params[:survey_member_id])
    @survey.toggle_admin(number)
    render :nothing => true
  end

  private

end
