require 'rails_helper'
require 'spec_helper'
include Warden::Test::Helpers
RSpec.describe Admin::TermsAndConditionsController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    @terms = FactoryBot.create(:term)
    sign_in @admin
  end
  describe "Post#new" do
    let(:params) do {
        description:"terms_and_conditions",
        for_whom: "client_users"
    }
    end
    it "create terms_and_conditions " do
      post :new, params: params
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#index" do
    it "show all data" do
      get :index
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#show" do
    it "show terms_and_conditions details" do
      get :show, params: {id: @terms.id}
      expect(response).to have_http_status(200)
    end
  end
  describe "Put#edit" do
    let(:params) do {
        description: "terms_and_conditions"
    }
    end
    it "edit terms_and_conditions" do
        put :edit, params: {id: @terms.id, terms: params}
        expect(response).to have_http_status(200)
    end
  end
end