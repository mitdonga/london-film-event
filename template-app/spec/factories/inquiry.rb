FactoryBot.define do
  factory :inquiry, class: "BxBlockInvoice::Inquiry" do
    user_id { "" }
    service_id { "" }
    sub_category_id { "" }
    note { "MyText" }
  end
end
