require 'rails_helper'

RSpec.describe AccountBlock::Account, type: :model do
    describe 'check_email_validation' do
        before(:each) do
            @company = create(:company)
        end
        it "should generate password" do
            user = AccountBlock::Account.new(
                first_name: "Rahul",
                last_name: "Patel",
                email: Faker::Internet.email,
                password: 'Test@1234',
                country_code: "91",
                account_type: "venue",
                phone_number: Faker::Base.numerify('89########'),
                company_id: @company.id
            )
            user.save!
            password = user.generate_password
            assert_equal user.authenticate(password), false
            assert_equal user.authenticate('Test@1234'), user
        end
    end
end