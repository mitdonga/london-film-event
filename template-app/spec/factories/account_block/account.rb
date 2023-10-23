FactoryBot.define do
    factory :admin_account, class: "AccountBlock::ClientAdmin" do
        first_name {Faker::Name.first_name }
        last_name { Faker::Name.last_name }
        email { Faker::Internet.email }
        password { Faker::Internet.password }
        type {'ClientAdmin'}
        country_code { "+91" }
        phone_number { Faker::Base.numerify('89########') }
        account_type { "venue" }
        full_phone_number {Faker::Base.numerify('+918#########')}
        activated {true}
        company_id { FactoryBot.create(:company).id }
    end

    factory :user_account, class: "AccountBlock::ClientUser" do
        first_name { Faker::Name.first_name }
        last_name { Faker::Name.last_name }
        email { Faker::Internet.email }
        password { Faker::Internet.password }
        type {'ClientUser'}
        country_code { "+91" }
        phone_number { Faker::Base.numerify('89########') }
        account_type { "venue" }
        full_phone_number {Faker::Base.numerify('+918#########')}
        activated {true}
        company_id { FactoryBot.create(:company).id }
        client_admin_id { FactoryBot.create(:client_admin).id }
        client_admin { FactoryBot.create(:client_admin) }
    end
end