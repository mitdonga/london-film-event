FactoryBot.define do
    CLASS_NAME = "AccountBlock::Account"
    factory :client_admin, class: CLASS_NAME do
        first_name { "Mit" }
        last_name { "Donga" }
        email { Faker::Internet.email }
        password { 'Test@1234' }
        type {'EmailAccount'}
        country_code { "+91" }
        phone_number { Faker::Base.numerify('89########') }
        account_type { "venue" }
        full_phone_number {Faker::Base.numerify('+918#########')}
        activated {true}
        company_id { FactoryBot.create(:company).id }
    end
end