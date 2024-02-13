require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::InquiriesController, type: :controller do
  include_context "setup data"
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    # @service = FactoryBot.create(:service)
    # 3.times do
    #   FactoryBot.create(:input_field, inputable: @service)
    # end

    sign_in @admin
  end
  describe "Get#inquiry" do
    it "show all services" do
      get :index
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#show" do
    it "show inquiry" do
      get :show, params: {id: @inquiry_1.id}
      expect(response).to have_http_status(200)
    end
  end
  describe "Put#edit" do
    it "edit inquiry" do
      put :update, params: {id: @inquiry_1.id, inquiry: {status: "approved"}}
      expect(response).to have_http_status(302)
    end
  end
end