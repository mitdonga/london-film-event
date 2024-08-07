module BxBlockHelpCentre
  class QuestionAnswer < BxBlockHelpCentre::ApplicationRecord
    self.table_name = :question_answers
    belongs_to :question_sub_type, optional: true
    validates :question, presence: { message: "Question required."}
  end
end
