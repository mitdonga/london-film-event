RSpec.shared_context "setup data" do

	before(:each, type: :controller) do

		FactoryBot.create(:email_template, 
			name: "User Account Creation (Mail To LF Admin)", 
			dynamic_words: "first_name, last_name, email, full_phone_number", 
			body: "Hi admin,
					New user added
					Name: {first_name} {last_name}
					Email: {email}
					Phone No: {full_phone_number}"
		)

		FactoryBot.create(:email_template, 
			name: "Client Admin Approving a Package", 
			dynamic_words: "user_name, service_name",
			body: "Hi {user_name}
					Your request for {service_name} package is approved by the admin."
		)

		FactoryBot.create(:email_template, 
			name: "Client User Request for Quote (All Packages or Previous Packages)", 
			dynamic_words: "user_name, service_name, sub_category_name, event_date",
			body: "Hi admin,
					{user_name} has request for quote. Package details are as below.
					Service: {service_name}
					Sub Category: {sub_category_name}
					Event Date: {event_date}
					For more details, visit the website."
		)

		FactoryBot.create(:email_template, 
			name: "Password Reset (Client User/Admin)", 
			dynamic_words: "first_name, password_reset_button",
			body: "Hi {first_name},
					Please click on the following button to reset your password.
					{password_reset_button}"
		)

		FactoryBot.create(:email_template, 
			name: "User Account Creation (Mail To User)", 
			dynamic_words: "user_name",
			body: "Hi {user_name} Welcome to London Film Event."
		)

		@company_1 = FactoryBot.create(:company)
		@company_2 = FactoryBot.create(:company)

		3.times do |index|
			service = FactoryBot.create(:service)

			FactoryBot.create(:sub_category, name: "Half Day",parent_id: service.id)
			FactoryBot.create(:sub_category, name: "Full Day",parent_id: service.id)
			FactoryBot.create(:sub_category, name: "Multi Day",parent_id: service.id)

			3.times do
				FactoryBot.create(:input_field, inputable: service)
				FactoryBot.create(:input_field_multi_option_value, inputable: service)
				FactoryBot.create(:input_field_multi_option_multiplier, inputable: service)
			end
			index == 0 ?
			FactoryBot.create(:input_field_date_values, inputable: service) :
			FactoryBot.create(:input_field_date_multiplier, inputable: service)
			
			FactoryBot.create(:event_start_time, inputable: service)
			FactoryBot.create(:event_start_time, name: "Event End Time", inputable: service)
			FactoryBot.create(:how_many_event_days, inputable: service)
		end
		@service_1 = BxBlockCategories::Service.first
		@service_2 = BxBlockCategories::Service.last
		@service_3 = BxBlockCategories::Service.second

		@client_admin_1 = FactoryBot.create(:admin_account, company_id: @company_1.id)
		@client_user_1 = FactoryBot.create(:user_account, client_admin_id: @client_admin_1.id)
		@token_1 = BuilderJsonWebToken.encode(@client_admin_1.id)
		@token_3 = BuilderJsonWebToken.encode(@client_user_1.id)
		@inquiry_1 = FactoryBot.create(:inquiry, user_id: @client_admin_1.id, service_id: @service_1.id, sub_category_id: @service_1.sub_categories.first.id)   
		@inquiry_2 = FactoryBot.create(:inquiry, user_id: @client_admin_1.id, service_id: @service_2.id, sub_category_id: @service_2.sub_categories.first.id, status: "pending")   
		@inquiry_3 = FactoryBot.create(:inquiry, user_id: @client_admin_1.id, service_id: @service_2.id, sub_category_id: @service_2.sub_categories.last.id, approved_by_client_admin_id: @client_admin_1.id, status: "approved")   

		@client_admin_2 = FactoryBot.create(:admin_account, company_id: @company_2.id)
		@token_2 = BuilderJsonWebToken.encode(@client_admin_2.id)

		@admin = AdminUser.create!(email: "#{Faker::Internet.user_name}@gmail.com", password: 'password', password_confirmation: 'password')
    	@admin.save
	end
end
	 	 	 	 	