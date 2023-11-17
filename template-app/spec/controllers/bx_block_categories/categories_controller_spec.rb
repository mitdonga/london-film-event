require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

RSpec.describe BxBlockCategories::CategoriesController, type: :controller do

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
end