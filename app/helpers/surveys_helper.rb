module SurveysHelper

  def display_welcome_message(survey)
    survey.use_welcome_message ? "display: inline" : "display: none"
  end

  def check_survey_availability_onblur
    remote_function(
      :url => {:controller => 'surveys', :action => 'check_name_available'},
      :with => "'name='+this.value",
      :loading => show_spinner('survey_name_spinner'),
      :complete => hide_spinner('survey_name_spinner')
    )
  end

  def count_sent_messages(survey)
    survey.messages.sent.size
  end

end
