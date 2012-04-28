class AddColumnsToSurveyStates < ActiveRecord::Migration
  def self.up
    add_column :survey_states, :phone_number_id, :integer
    add_column :survey_states, :survey_id, :integer
    add_column :survey_states, :survey_question_id, :integer
  end

  def self.down
    remove_column :survey_states, :phone_number_id
    remove_column :survey_states, :survey_id
    remove_column :survey_states, :survey_question_id
  end
end
