FactoryBot.define do
    factory :term, class: "BxBlockTermsAndConditions::TermsAndCondition" do
        description { Faker::Lorem.paragraph(sentence_count: 200) }
        for_whom {"client_users"}
    end
end