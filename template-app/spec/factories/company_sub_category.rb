FactoryBot.define do
    factory :company_sub_category, class: "BxBlockInvoice::CompanySubCategory" do
        company_id { FactoryBot.create(:company).id}
        sub_category_id { FactoryBot.create(:sub_category).id}
        price { 1000 }
    end
end