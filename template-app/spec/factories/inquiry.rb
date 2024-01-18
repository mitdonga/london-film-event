FactoryBot.define do
  factory :inquiry, class: "BxBlockInvoice::Inquiry" do
    user_id { FactoryBot.create(:admin_account).id }
    service_id { FactoryBot.create(:service).id }
    sub_category_id { FactoryBot.create(:sub_category).id }
    note { Faker::Lorem.paragraph_by_chars }
    status {"draft"}
  end
end
