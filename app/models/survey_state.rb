class SurveyState < ActiveRecord::Base
  belongs_to :phone_number
  belongs_to :survey
  belongs_to :survey_question

  validates_presence_of :survey_id
  validates_presence_of :survey_question_id
  validates_presence_of :phone_number_id

  def handle_message(num, msg)
    puts ("save answer")
    SurveyAnswer.create(:survey_question => self.survey_question, :response_text => msg, :phone_number_id => num.id, :survey_id => survey.id)

    puts("ask next survey question: ")

    next_q_idx = self.survey_question.position + 1
    next_q = SurveyQuestion.find(:all, :conditions => { :position => next_q_idx } ).first
    if (next_q != nil) 
      self.survey.list.create_outgoing_message(num, next_q.question_text)
      self.survey_question = next_q
      self.save
    else
      self.survey.list.create_outgoing_message(num, "Thanks for completing the survey!")
    end
  end
end
