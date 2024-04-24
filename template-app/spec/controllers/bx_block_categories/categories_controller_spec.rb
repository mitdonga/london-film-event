require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe BxBlockCategories::CategoriesController, type: :controller do
  include_context "setup data"

  before do 

  end


  describe "#index" do

    it "should show all services" do
      get "index", params: { token: @token_1 }
      expect(response).to have_http_status(200)
    end

    it "should return not content" do
      @company_2.company_categories.update_all(has_access: false)

      get "index", params: { token: @token_2 }
      expect(response).to have_http_status(204)
    end
  end

  describe "#previous_packages" do

    it "should return previous packages" do
      get "previous_packages", params: { token: @token_1 }
      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["data"].size).to be > 0
    end

    it "should return not content" do

      get "previous_packages", params: { token: @token_2 }
      expect(response).to have_http_status(204)
      expect(response.body).to include("Previous packages not found")
    end
  end

  describe "#get_service" do

    it "should show service" do
      get "get_service", params: { token: @token_1, sub_category_id: @client_admin_1.available_sub_categories.first.id }
      expect(response).to have_http_status(200)
    end

    it "should raise error" do
      get "get_service", params: { token: @token_1 }
      expect(response).to have_http_status(422)
      expect(response.body).to include("Invalid sub category")
    end
  end

  describe "#form_fields" do
    let(:sub_category) { @client_admin_1.available_sub_categories.first }
    let(:service) { sub_category.parent }

    it "should show default_coverage and input_fields" do
      get "form_fields", params: { token: @token_1, sub_category_id: sub_category.id, service_id: service.id }
      expect(response).to have_http_status(200)
    end

    it "should raise invalid params" do
      get "form_fields", params: { token: @token_1 }
      expect(response).to have_http_status(422)
      expect(response.body).to include("Provide valid service and sub category ids")
    end

    it "should raise service or sub_category not found" do
      get "form_fields", params: { token: @token_1, sub_category_id: 10000, service_id: 2321 }
      expect(response).to have_http_status(422)
      expect(response.body).to include("Service or sub category not found")
    end
  end

  describe "#create_company_bespoke_service" do
    let(:service_name) { "Builder ai bespoke service"}
    let(:base_service_id) { @service_1.id }
    let(:company_id) { @company_1.id }
    let(:sub_category) { "Full Day" }
    let(:secondary_service_ids) { [@service_2.id, @service_3.id]}

    it "should create new bespoke service" do
      post 'create_company_bespoke_service', params: {service_name: service_name, base_service_id: base_service_id, company_id: company_id, sub_category: sub_category, secondary_service_ids: secondary_service_ids}
      expect(response).to have_http_status(200)
      expect(response.body).to include("Bespoke service successfully created")
    end
    it "should create new bespoke service" do
      post 'create_company_bespoke_service', params: {service_name: service_name, base_service_id: base_service_id, company_id: company_id}
      expect(response).to have_http_status(422)
      expect(response.body).to include("Please enter valid data")
    end
  end
end