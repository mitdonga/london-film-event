FactoryBot.define do
    factory :email_template, class: "BxBlockEmailNotifications::EmailTemplate" do
      name { Faker::Lorem.sentence(word_count: 4) }
      body { Faker::Lorem.paragraph_by_chars }
    end
  end
  