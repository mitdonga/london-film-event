require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe BxBlockInvoice::InvoiceController, type: :controller do

  before do 
    @company_1 = FactoryBot.create(:company)
    @company_2 = FactoryBot.create(:company)

    3.times do
      service = FactoryBot.create(:service)
      3.times do
        FactoryBot.create(:sub_category, parent_id: service.id)
      end
      3.times do
        FactoryBot.create(:input_field, inputable: service)
        FactoryBot.create(:input_field_multi_option_value, inputable: service)
        FactoryBot.create(:input_field_multi_option_multiplier, inputable: service)
      end
    end
    @service_1 = BxBlockCategories::Service.first
    @service_2 = BxBlockCategories::Service.last

    @client_admin_1 = FactoryBot.create(:admin_account, company_id: @company_1.id)
    @token_1 = BuilderJsonWebToken.encode(@client_admin_1.id)
    @inquiry_1 = FactoryBot.create(:inquiry, user_id: @client_admin_1.id, service_id: @service_1.id, sub_category_id: @service_1.sub_categories.first.id)   

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

    it "should raise error" do
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
end