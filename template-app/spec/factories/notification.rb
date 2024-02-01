FactoryBot.define do
  factory :notification, class: "BxBlockNotifications::Notification" do
    headings {  Faker::Lorem.sentence(word_count: 3) }
    contents { Faker::Lorem.paragraph }
  end
end
