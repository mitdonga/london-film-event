FactoryBot.define do
    factory :service, class: "BxBlockCategories::Service" do
        name { Faker::Lorem.sentence(word_count: 5) }
        description { Faker::Lorem.paragraph(sentence_count: 200) }
        company_id {nil}
    end
end