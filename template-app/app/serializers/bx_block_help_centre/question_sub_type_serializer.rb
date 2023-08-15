module BxBlockHelpCentre
  class QuestionSubTypeSerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer
    attributes *[
        :id,
        :sub_type,
        :description,
        :created_at,
        :updated_at,
        :question_answers
    ]
    attribute :question_answers do |object|
      BxBlockHelpCentre::QuestionAnswerSerializer.new(object.question_answers)
    end
  end
end
