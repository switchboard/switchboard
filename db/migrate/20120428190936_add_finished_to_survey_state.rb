class AddFinishedToSurveyState < ActiveRecord::Migration
  def self.up
    add_column :survey_states, :finished, :boolean, :default => false
  end

  def self.down
    remove_column :survey_states, :finished
  end
end
