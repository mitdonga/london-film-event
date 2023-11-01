FactoryBot.define do
    factory :sub_category, class: "BxBlockCategories::SubCategory" do
        name { Faker::Lorem.sentence(word_count: 2) }
        description { Faker::Lorem.paragraph(sentence_count: 2) }
        duration {4}
        start_from {4000}
        parent_id {FactoryBot.create(:category).id}
    end
end