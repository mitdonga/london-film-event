FactoryBot.define do
  factory :input_value, class: "BxBlockCategories::InputValue" do
    company_input_field_id { FactoryBot.create(:company_input_field).id  }
    additional_service_id { FactoryBot.create(:additional_service).id  }
    user_input { Faker::Lorem.word }
    cost { rand(100..1000) }
  end
end
