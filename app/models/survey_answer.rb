class SurveyAnswer < ActiveRecord::Base
  
  validates_presence_of         :response_text, :survey_question_id, :phone_number_id, :survey_id
end
