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
	end
end

 	 	 	 	 	