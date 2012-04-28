class AddStatusToSurveyStates < ActiveRecord::Migration
  def self.up
    add_column :survey_states, :status, :boolean
  end

  def self.down
    remove_column :survey_states, :status
  end
end
