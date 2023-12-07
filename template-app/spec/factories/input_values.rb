FactoryBot.define do
  factory :input_value, class: "BxBlockCategories::InputValue" do
    input_field_id { "" }
    additional_service_id { "" }
    user_input { "MyString" }
    const { 100 }
  end
end
