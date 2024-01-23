require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe BxBlockInvoice::InvoiceController, type: :controller do
  include_context "setup data"
  
  before do 
    @company_1 = FactoryBot.create(:company)
    @company_2 = FactoryBot.create(:company)

    3.times do |index|
      service = FactoryBot.create(:service)
      3.times do
        FactoryBot.create(:sub_category, parent_id: service.id)
      end
      3.times do
        FactoryBot.create(:input_field, inputable: service)
        FactoryBot.create(:input_field_multi_option_value, inputable: service)
        FactoryBot.create(:input_field_multi_option_multiplier, inputable: service)
      end
      index == 0 ?
      FactoryBot.create(:input_field_date_values, inputable: service) :
      FactoryBot.create(:input_field_date_multiplier, inputable: service)
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
  end

  describe "#create_inquiry" do
    it "should create inquiry" do
      sub_category = @service_1.sub_categories.last
      post "create_inquiry", params: { token: @token_1, inquiry: {service_id: @service_1.id, sub_category_id: sub_category.id} }
      data = JSON.parse(response.body)
      expect(response).to have_http_status(201)
      expect(response.body).to include("Inquiry successfully created")
      expect(data["inquiry"]["data"]["attributes"]["base_service_detail"]["data"].present?).to eq true
      expect(data["inquiry"]["data"]["attributes"]["extra_services_detail"]["data"].present?).to eq false
    end

    it "will raise error" do
      sub_category = @service_2.sub_categories.first
      post "create_inquiry", params: { token: @token_1, inquiry: {service_id: @service_1.id, sub_category_id: sub_category.id} }
      expect(response).to have_http_status(422)
      expect(response.body).to include("Selected sub category doesn't belongs to selected service")
    end
  end

  describe "#inquiry" do
    it "should create inquiry" do
      FactoryBot.create(:additional_service, inquiry_id: @inquiry_1.id, service_id: @service_2.id)
      get "inquiry", params: { token: @token_1, id: @inquiry_1.id }
      data = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(response.body).to include("Success")
      expect(data["inquiry"]["data"]["attributes"]["base_service_detail"]["data"].present?).to eq true
      expect(data["inquiry"]["data"]["attributes"]["extra_services_detail"]["data"].size).to eq 1
    end

    it "should raise not found" do
      sub_category = @service_2.sub_categories.first
      get "inquiry", params: { token: @token_1, id: 110 }
      expect(response).to have_http_status(422)
      expect(response.body).to include("Inquiry not found")
    end
  end

  describe "#manage_additional_services" do
    it "should success" do
      FactoryBot.create(:additional_service, inquiry_id: @inquiry_1.id, service_id: @service_2.id)
      put "manage_additional_services", params: { token: @token_1, inquiry_id: @inquiry_1.id, service_ids: [@service_1.id, @service_3.id] }
      data = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(data["extra_services_detail"]["data"].size).to eq 1
    end

    it "should create two additional services" do
      put "manage_additional_services", params: { token: @token_1, inquiry_id: @inquiry_1.id, service_ids: [@service_2.id, @service_3.id] }
      data = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(data["extra_services_detail"]["data"].size).to eq 2
    end

    it "should raise invalid service_ids" do
      put "manage_additional_services", params: { token: @token_1, inquiry_id: @inquiry_1.id, service_ids: ["Invalid service_ids"] }
      expect(response).to have_http_status(422)
      expect(response.body).to include("service_ids should numeric array")
    end

    it "should raise inquiry not found" do
      put "manage_additional_services", params: { token: @token_1, inquiry_id: 1011 }
      expect(response).to have_http_status(404)
      expect(response.body).to include("Inquiry with ID 1011 not found")
    end

    it "should raise invalid inquiry" do
      put "manage_additional_services", params: { token: @token_1, service_ids: ["wrong sub"] }
      expect(response).to have_http_status(422)
      expect(response.body).to include("Please provide valid inquiry id")
    end
  end

  describe "#save_inquiry" do
    before do
      FactoryBot.create(:additional_service, inquiry_id: @inquiry_1.id, service_id: @service_2.id)
      FactoryBot.create(:additional_service, inquiry_id: @inquiry_1.id, service_id: @service_3.id)
      @input_values = @inquiry_1.input_values
    end
    let(:input_values) do [
      {id: @input_values[0].id, user_input: "4"},
      {id: @input_values[1].id, user_input: "10"},
      {id: @input_values[2].id, user_input: "100"},
      {id: 1001, user_input: "120"},
     ] end
    it "should save inquiry" do
      put "save_inquiry", params: { token: @token_1, inquiry_id:  @inquiry_1.id,  input_values: input_values }
      expect(response).to have_http_status(200)
    end
  end

  describe "#calculate_cost success" do
    before do
      @inquiry_1.input_values.each do |input_value|
        input_field = input_value.current_input_field
        if input_field.field_type == "multiple_options"
          input_value.update(user_input: input_field.options.split(", ")[1])
        elsif input_field.field_type == "calender_select"
          input_value.update(user_input: Date.today + 10.days)
        end 
      end
    end

    it "should calculate cost" do
      put "calculate_cost", params: { token: @token_1, inquiry_id:  @inquiry_1.id }
      inquiry = JSON.parse(response.body)["inquiry"]
      expect(response).to have_http_status(200)
      expect(inquiry["data"]["attributes"]["package_sub_total"]).to be > 0
      expect(inquiry["data"]["attributes"]["addon_sub_total"]).to be > 0
    end
  end

  describe "#calculate_cost error" do
    before do
      @inquiry_1.input_values.each do |input_value|
        input_field = input_value.current_input_field
        if input_field.field_type == "multiple_options"
          input_value.update(user_input: input_field.options.split(", ").last)
        elsif input_field.field_type == "calender_select"
          input_value.update(user_input: (Date.today + 3.days).to_s)
        end 
      end
    end

    it "should raise error" do
      put "calculate_cost", params: { token: @token_1, inquiry_id:  @inquiry_1.id }
      expect(response).to have_http_status(422)
    end
  end

  describe "#upload_attachment" do
    before do
      @file = fixture_file_upload("files/test.txt", 'text')
    end
    it "should upload the file" do
      put "upload_attachment", params: {token: @token_1, inquiry_id:  @inquiry_1.id, attachment: @file }
      expect(response).to have_http_status(200)
      expect(response.body).to include("File successfully uploaded")
    end

    it "should remove the file" do
      put "upload_attachment", params: {token: @token_1, inquiry_id:  @inquiry_1.id, attachment: nil }
      expect(response).to have_http_status(200)
      expect(response.body).to include("File successfully removed")
    end
  end

  describe "#submit_inquiry" do
    it "should submit inquiry" do
      put "submit_inquiry", params: {token: @token_1, inquiry_id:  @inquiry_1.id}
      expect(response).to have_http_status(200)
      expect(response.body).to include("Inquiry successfully submitted")
    end

    context 'if errors present' do
      before do
        @inquiry_1.input_values.each do |input_value|
          input_field = input_value.current_input_field
          if input_field.field_type == "multiple_options"
            input_value.update(user_input: input_field.options.split(", ").last)
          elsif input_field.field_type == "calender_select"
            input_value.update(user_input: (Date.today + 3.days).to_s)
          end 
        end
      end
      it "raise error" do
        put "submit_inquiry", params: {token: @token_1, inquiry_id:  @inquiry_1.id}
        expect(response).to have_http_status(422)
        expect(response.body).to include("Invalid data entered")
      end
    end
  end

  describe "#inquiries" do
    it "should return draft inquiries" do
      get "inquiries", params: {token: @token_1, status: "draft"}
      expect(response).to have_http_status(200)
      expect(response.body).to include("1 inquiries found")
    end
  end

  describe "all inquiries" do
    it "should return all inquiries" do
      get "inquiries", params: {token: @token_1}
      expect(response).to have_http_status(200)
      expect(response.body).to include("3 inquiries found")
    end
  end

  describe "pending inquiries" do
    it "should return pending inquiries" do
      get "inquiries", params: {token: @token_1, status: "pending"}
      expect(response).to have_http_status(200)
      expect(response.body).to include("1 inquiries found")
    end
  end

  describe "approved inquiries" do
    it "should return approved inquiries" do
      get "inquiries", params: {token: @token_1, status: "approved"}
      expect(response).to have_http_status(200)
      expect(response.body).to include("1 inquiries found")
    end
  end

  describe "manage users inquiries" do
    it "should return client admin and associated users inquiries" do
      get "manage_users_inquiries", params: {token: @token_1}
      expect(response).to have_http_status(200)
    end
  end
end