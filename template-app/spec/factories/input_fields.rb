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
    options { "4+ weeks away, 2 - 3 weeks away, 1 - 2 weeks away, <1 week away" }
    values { (100..200).to_a.sample(3).join(", ") + ", Speak to expert" }
    default_value { 121 }
    inputable { FactoryBot.create(:category) }
  end

  factory :input_field_date_multiplier, class: "BxBlockCategories::InputField" do
    name { "Event Date" }
    field_type { 'calender_select' }
    section { "required_information" }
    options { "4+ weeks away, 2 - 3 weeks away, 1 - 2 weeks away, <1 week away" }
    multiplier { (1..10).to_a.sample(3).join(", ") + ", Speak to expert" }
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
end
