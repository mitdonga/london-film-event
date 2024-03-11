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
    values { (100..200).to_a.sample(3).join(", ") + ", Speak to expert" }
    inputable { FactoryBot.create(:category) }
  end

  factory :input_field_multi_option_multiplier, class: "BxBlockCategories::InputField" do
    name { Faker::Lorem.sentence(word_count: 10) }
    field_type { 'multiple_options' }
    section { "addon" }
    options { Faker::Lorem.words(number: 4).join(", ") }
    multiplier { (1..10).to_a.sample(3).join(", ") + ", Speak to expert" }
    default_value { 121 }
    inputable { FactoryBot.create(:category) }
  end

  factory :input_field_date_values, class: "BxBlockCategories::InputField" do
    name { "Event Date" }
    field_type { 'calender_select' }
    section { "required_information" }
    options { "29+ days away, 15 - 28 days away, 8 - 14 days away, 3 - 7 days away, <3 days away" }
    values { (100..200).to_a.sample(5).join(", ") }
    default_value { 121 }
    inputable { FactoryBot.create(:category) }
  end

  factory :input_field_date_multiplier, class: "BxBlockCategories::InputField" do
    name { "Event Date" }
    field_type { 'calender_select' }
    section { "required_information" }
    options { "29+ days away, 15 - 28 days away, 8 - 14 days away, 3 - 7 days away, <3 days away" }
    multiplier { (1..10).to_a.sample(5).join(", ") }
    default_value { 121 }
    inputable { FactoryBot.create(:category) }
  end

  factory :event_start_time, class: "BxBlockCategories::InputField" do
    name { "Event Start Time" }
    field_type { 'date_time' }
    section { "required_information" }
    options { }
    multiplier { }
    default_value { }
    inputable { FactoryBot.create(:category) }
  end

  factory :how_many_days_coverage, class: "BxBlockCategories::InputField" do
    name { "How Many Days Coverage?" }
    field_type { 'multiple_options' }
    section { "required_information" }
    options { "0.5, 1, 2, 3+" }
    multiplier { "1, 2, 3, 4" }
    default_value { 231 }
    inputable { FactoryBot.create(:category) }
  end
end
