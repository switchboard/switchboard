class CreateSurveyStates < ActiveRecord::Migration
  def self.up
    create_table :survey_states do |t|
      t.integer :phone_number_id
      t.integer :survey_id
      t.integer :survey_question_id
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_states
  end
end
