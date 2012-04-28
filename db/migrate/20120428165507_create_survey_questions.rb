class CreateSurveyQuestions < ActiveRecord::Migration
  def self.up
    create_table :survey_questions do |t|

      t.int         :question_type
      t.int         :survey_id
      t.string      :name
      t.string      :question_text 
      t.timestamps
    end
  end

  def self.down
    drop_table :survey_questions
  end
end
