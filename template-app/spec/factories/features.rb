FactoryBot.define do
  factory :feature do
    name { "Some Feature.." }
    sub_category_id { FactoryBot.create(:sub_category).id }
  end
end
