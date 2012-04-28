class SurveyQuestion < ActiveRecord::Base

  belongs_to      :survey
  validates_presence_of       :name    
  validates_presence_of       :question_text
  validates_presence_of       :survey_id
end
