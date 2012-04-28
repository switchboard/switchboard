class AddPositionToSurveyQuestions < ActiveRecord::Migration
  def self.up
    add_column :survey_questions, :position, :integer
  end

  def self.down
    remove_column :survey_questions, :position
  end
end
