FactoryBot.define do
    factory :email_template, class: "BxBlockEmailNotifications::EmailTemplate" do
	      name { Faker::Lorem.sentence(word_count: 4) }
	      body { "<h4>Hi {user_name}</h4> <br> <p>" + Faker::Lorem.paragraph_by_chars + "</p>" }
	      dynamic_words { "user_name" }
    end
 end
  