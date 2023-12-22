FactoryBot.define do
  factory :contact, class: "BxBlockContactUs::Contact" do
    first_name { Faker::Lorem.sentence(word_count: 2) }
    last_name { Faker::Lorem.sentence(word_count: 2) }
    subject { Faker::Lorem.paragraph(sentence_count: 200) }
    details { Faker::Lorem.paragraph(sentence_count: 200) }
    email { Faker::Internet.email }
    country_code { Faker::Address.country_code }
    phone_number do
      Faker::Number.number(digits: 10)
    end
  end
end