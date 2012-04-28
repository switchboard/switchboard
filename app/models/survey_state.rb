class SurveyState < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  belongs_to :survey_question
end
