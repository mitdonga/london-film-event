FactoryBot.define do
    factory :category, class: "BxBlockCategories::Category" do
        name { Faker::Lorem.sentence(word_count: 2) }
        description { Faker::Lorem.paragraph(sentence_count: 200) }
        catalogue_type {"all_packages"}
        start_from {200}
        status {"unarchived"}
    end
end