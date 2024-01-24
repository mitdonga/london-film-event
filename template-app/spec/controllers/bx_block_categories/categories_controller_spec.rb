require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe BxBlockCategories::CategoriesController, type: :controller do
  include_context "setup data"

  before do 
    @company_1 = FactoryBot.create(:company)
    @company_2 = FactoryBot.create(:company)

    @client_admin_1 = FactoryBot.create(:admin_account, company_id: @company_1.id)
    @token_1 = BuilderJsonWebToken.encode(@client_admin_1.id)

    @client_admin_2 = FactoryBot.create(:admin_account, company_id: @company_2.id)
    @token_2 = BuilderJsonWebToken.encode(@client_admin_2.id)

    3.times do
      service = FactoryBot.create(:service)
      sub_category = FactoryBot.create(:sub_category, parent_id: service.id)
    end

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
end