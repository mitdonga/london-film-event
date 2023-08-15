module BxBlockHelpCentre
  class QuestionSubType < BxBlockHelpCentre::ApplicationRecord
    self.table_name = :question_sub_types
    belongs_to :question_type
    has_many :question_answers, :dependent => :destroy
    validates :sub_type, presence: { message: "Question sub type required."}
  end
end
