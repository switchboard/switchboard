class SurveyState < ActiveRecord::Base
  belongs_to :phone_number
  belongs_to :survey
  belongs_to :survey_question

  validates_presence_of :survey_id
  validates_presence_of :survey_question_id
  validates_presence_of :phone_number_id
end
