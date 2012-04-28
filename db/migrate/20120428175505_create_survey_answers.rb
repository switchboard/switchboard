class CreateSurveyAnswers < ActiveRecord::Migration
  def self.up
    create_table :survey_answers do |t|

      t.integer         :survey_question_id
      t.string          :response_text
      t.integer         :phone_number_id
      t.integer         :survey_id
      t.timestamps
    end
  end

  def self.down
    drop_table :survey_answers
  end
end
