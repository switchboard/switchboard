# Methods added to this helper will be available to all templates in the application.
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
    sent_state = MessageState.find_by_name('sent')
    survey.messages.in_state(sent_state.id).to_s
  end

end
