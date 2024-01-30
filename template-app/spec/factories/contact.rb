FactoryBot.define do
  factory :contact, class: "BxBlockContactUs::Contact" do
    first_name { Faker::Lorem.sentence(word_count: 2) }
    last_name { Faker::Lorem.sentence(word_count: 2) }
    subject { Faker::Lorem.paragraph(sentence_count: 200) }
    details { "Lorem ipsum dolor sit amet, consectetur adipiscing elit." }
    email { "#{Faker::Internet.user_name}@gmail.com" }
    country_code { Faker::Address.country_code }
    phone_number do
      Faker::Number.number(digits: 10)
    end
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'sample.pdf'), 'application/pdf') }
  end
end