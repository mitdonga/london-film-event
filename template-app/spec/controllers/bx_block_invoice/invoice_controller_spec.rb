require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe BxBlockInvoice::InvoiceController, type: :controller do
  include_context "setup data"
  
  before do 
    
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
      @esi = @inquiry_1.input_values.joins(:input_field).where("input_fields.name = ?", "Event Start Time").first
      @eei = @inquiry_1.input_values.joins(:input_field).where("input_fields.name = ?", "Event End Time").first
    end
    let(:input_values) do [
      {id: @input_values[0].id, user_input: "4"},
      {id: @input_values[1].id, user_input: "10"},
      {id: @input_values[2].id, user_input: "100"},
      {id: 1001, user_input: "120"},
      {id: @esi.id, user_input: (Time.now + 10.days).to_s},
      {id: @eei.id, user_input: (Time.now + 10.days + 3.hours).to_s},
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
      put "upload_attachment", params: {token: @token_1, inquiry_id:  @inquiry_1.id, files: [@file] }
      expect(response).to have_http_status(200)
      expect(response.body).to include("Success")
    end

    it "should remove the file" do
      put "upload_attachment", params: {token: @token_1, inquiry_id:  @inquiry_1.id, remove_file_ids: [1] }
      expect(response).to have_http_status(422)
      expect(response.body).to include("Something went wrong")
    end
  end

  describe "#submit_inquiry" do
    it "should submit inquiry" do
      put "submit_inquiry", params: {token: @token_1, inquiry_id:  @inquiry_1.id, new_status: "pending"}
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
        put "submit_inquiry", params: {token: @token_1, inquiry_id:  @inquiry_1.id, new_status: "pending"}
        expect(response).to have_http_status(422)
        expect(response.body).to include("Invalid data entered")
      end
    end
  end

  describe "#inquiries" do
    it "should return draft inquiries" do
      get "inquiries", params: {token: @token_1, status: "draft"}
      expect(response).to have_http_status(200)
    end
  end

  describe "all inquiries" do
    it "should return all inquiries" do
      get "inquiries", params: {token: @token_1}
      expect(response).to have_http_status(200)
    end
  end

  describe "pending inquiries" do
    it "should return pending inquiries" do
      get "inquiries", params: {token: @token_1, status: "pending"}
      expect(response).to have_http_status(200)
    end
  end

  describe "approved inquiries" do
    it "should return approved inquiries" do
      get "inquiries", params: {token: @token_1, status: "approved"}
      expect(response).to have_http_status(200)
    end
  end

  describe "Approved inquiry" do
    it "should raise inquiry not in pending" do
      put "approve_inquiry", params: {token: @token_1, inquiry_id: @inquiry_3.id}
      expect(response).to have_http_status(422)
      expect(response.body).to include("Inquiry is not in pending state")
    end

    it "should return success" do
      put "approve_inquiry", params: {token: @token_1, inquiry_id: @inquiry_2.id}
      expect(response).to have_http_status(200)
      expect(response.body).to include("Success")
    end
  end

  describe "manage users inquiries" do
    it "should return client admin and associated users inquiries" do
      get "manage_users_inquiries", params: {token: @token_1}
      expect(response).to have_http_status(200)
    end

    it "should return client users themselves inquiries" do
      get "manage_users_inquiries", params: {token: @token_3}
      expect(response).to have_http_status(200)
    end
  end

  describe "fetch invoices" do
    it "should return invoices" do
      get "user_invoices", params: {token: @token_1}
      expect(response).to have_http_status(200)
    end

    it "should download invoice" do
      get "invoice_pdf", params: {token: @token_1, invoice_uid: "913cf561-5f02-450a-9fcc-3f868f4ce8a"}
      expect(response).to have_http_status(422)
      expect(response.body).to include("Failed to download invoice PDF")
    end
  end

  describe "Change invoice inquiry sub category" do
    before do      
    end

    it "should change to multi day" do
      input_values = @inquiry_1.input_values
      input = @inquiry_1.input_values.joins(:input_field).where("input_fields.name ilike ?", "%how many days coverage%").first
      input.update(user_input: "2")

      post "change_inquiry_sub_category", params: {token: @token_1, inquiry_id: @inquiry_1.id}
      expect(response).to have_http_status(200)
    end

    it "should change to half day" do
      input_values = @inquiry_1.input_values
      input = @inquiry_1.input_values.joins(:input_field).where("input_fields.name ilike ?", "%how many days coverage%").first
      input.update(user_input: "0.5")

      post "change_inquiry_sub_category", params: {token: @token_1, inquiry_id: @inquiry_1.id}
      expect(response).to have_http_status(200)
    end

    it "should raise error while changing" do
      post "change_inquiry_sub_category", params: {token: @token_1, inquiry_id: @inquiry_1.id}
      expect(response).to have_http_status(422)
    end
  end

  describe "Delete User Inquiries" do
    it "should delete all inquiries of user" do
      delete "delete_user_inquiries", params: {token: @token_1, user_id: @client_admin_2.id}
      expect(response).to have_http_status(200)
    end

    it "should raise user not found error" do
      delete "delete_user_inquiries", params: {token: @token_1, user_id: 10101}
      expect(response).to have_http_status(422)
    end
  end

  describe "Delete Inquiry" do
    it "should delete inquiry" do
      delete "delete_inquiry", params: {token: @token_1, inquiry_id: @inquiry_1.id}
      expect(response).to have_http_status(200)
    end
  end
end