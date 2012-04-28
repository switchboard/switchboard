class SurveyAnswer < ActiveRecord::Base
  belongs_to :phone_number
  belongs_to :survey
  belongs_to :survey_question
  
  validates_presence_of         :response_text, :survey_question_id, :phone_number_id, :survey_id
end
