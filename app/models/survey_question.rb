class SurveyQuestion < ActiveRecord::Base

  belongs_to      :survey
  validates       :name,          :presence => true
  validates       :question_text, :presence => true
  validates       :survey_id,     :presence => true
end
