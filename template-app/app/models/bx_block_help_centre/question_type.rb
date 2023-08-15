module BxBlockHelpCentre
  class QuestionType < BxBlockHelpCentre::ApplicationRecord
    self.table_name = :question_types
    has_many :question_sub_types, :dependent => :destroy
    has_many :question_answers, through: :question_sub_types
    validates :que_type, presence: { message: "Question type required."}
    validates :que_type, uniqueness: {
      case_sensitive: false, message: "Question type already exists."
    }
    accepts_nested_attributes_for :question_sub_types
  end
end
