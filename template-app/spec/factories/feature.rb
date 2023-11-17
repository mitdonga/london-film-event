FactoryBot.define do
  factory :feature, class: "BxBlockCategories::Feature"  do
    name { "Some Feature.." }
    sub_category_id { FactoryBot.create(:sub_category).id }
  end
end
