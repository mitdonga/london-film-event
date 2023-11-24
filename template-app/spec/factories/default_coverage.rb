FactoryBot.define do
  factory :default_coverage do
    title { "MyString" }
    rank { 1 }
    category { 1 }
    sub_category_id { FactoryBot.create(:sub_category).id }
  end
end
