FactoryBot.define do
    factory :question_answer, class: "BxBlockHelpCentre::QuestionAnswer" do
      question {  Faker::Lorem.question }
      answer { Faker::Lorem.paragraph }
    end
end
  