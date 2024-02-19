require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::BespokeInquiriesController, type: :controller do
  include_context "setup data"
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save

    sign_in @admin
  end
  describe "Get#inquiry" do
    it "show all bespoke inquiries" do
      get :index
      expect(response).to have_http_status(200)
    end
  end
  describe "Get#show" do
    it "show bespoke inquiry" do
      get :show, params: {id: @bspk_inquiry_1.id}
      expect(response).to have_http_status(200)
    end
  end
  describe "Put#edit" do
    it "edit bespoke inquiry" do
      put :update, params: {id: @bspk_inquiry_1.id, inquiry: {status: "approved"}}
      expect(response).to have_http_status(302)
    end
  end
end