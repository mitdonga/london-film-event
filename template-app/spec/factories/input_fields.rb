FactoryBot.define do
  factory :input_field, class: "BxBlockCategories::InputField" do
    name { Faker::Lorem.sentence(word_count: 2) }
    field_type { 0 }
    inputable { FactoryBot.create(:category) }
  end
end
