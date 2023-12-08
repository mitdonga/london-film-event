FactoryBot.define do
  factory :additional_service, class: "BxBlockCategories::AdditionalService" do
    inquiry_id { FactoryBot.create(:inquiry).id  }
    service_id { FactoryBot.create(:service).id }
  end
end
