module BxBlockHelpCentre
  class QuestionTypeSerializer < BuilderBase::BaseSerializer
    include FastJsonapi::ObjectSerializer
    attributes *[
        :id,
        :que_type,
        :description,
        :created_at,
        :updated_at,
        :question_sub_types
    ]
    attribute :question_sub_types do |object|
      BxBlockHelpCentre::QuestionSubTypeSerializer.new(object.question_sub_types)
    end
  end
end
