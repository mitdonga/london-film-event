FactoryBot.define do
    CLASS_NAME = "BxBlockInvoice::Company"
    factory :company, class: CLASS_NAME do
        name { "Builder AI" }
        address { "Abc street, London, UK" }
        city { "London" }
        zip_code { "10001" }
        phone_number { Faker::Base.numerify('+918#########') }
        email { Faker::Internet.email }
    end
end