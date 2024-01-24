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
                country_code: "91",
                account_type: "venue",
                phone_number: Faker::Base.numerify('89########'),
                company_id: @company.id
            )
            user.save!
            password = user.generate_password
            assert_equal user.authenticate(password), user
            assert_equal user.authenticate('Test@1234'), false
        end
    end

    describe '#invalidate_token' do
        it 'updates token expiration and session duration' do
        account = create(:account, last_visit_at: Time.current - 1.hour) 
        fixed_time = Time.current
        allow(Time).to receive(:current).and_return(fixed_time)

        account.invalidate_token

        reloaded_account = AccountBlock::Account.find(account.id)

        expect(reloaded_account.token_expires_at).to be_within(1.second).of(fixed_time)

        expected_session_duration = "#{1} hours, #{0} minutes" 
        expect(reloaded_account.session_duration).to eq(expected_session_duration)
        end
    end
end