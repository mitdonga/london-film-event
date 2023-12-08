FactoryBot.define do
  factory :input_field, class: "BxBlockCategories::InputField" do
    name { Faker::Lorem.sentence(word_count: 6) }
    field_type { "text" }
    section { "required_information" }
    inputable { FactoryBot.create(:category) }
  end

  factory :input_field_multi_option_value, class: "BxBlockCategories::InputField" do
    name { Faker::Lorem.sentence(word_count: 10) }
    field_type { "multiple_options" }
    section { "addon" }
    options { Faker::Lorem.words(number: 4).join(", ") }
    values { (100..200).to_a.sample(4).join(", ") }
    inputable { FactoryBot.create(:category) }
  end

  factory :input_field_multi_option_multiplier, class: "BxBlockCategories::InputField" do
    name { Faker::Lorem.sentence(word_count: 10) }
    field_type { 'multiple_options' }
    section { "addon" }
    options { Faker::Lorem.words(number: 4).join(", ") }
    values { (1..10).to_a.sample(4).join(", ") }
    default_value { 121 }
    inputable { FactoryBot.create(:category) }
  end
end
