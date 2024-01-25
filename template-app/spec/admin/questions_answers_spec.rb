require 'rails_helper'
require 'spec_helper'
require 'factory_bot'

include Warden::Test::Helpers

RSpec.describe Admin::FaQsController, type: :controller do
  render_views
  before(:each) do
    @admin = AdminUser.create!(email: 'test123@example.com', password: 'password', password_confirmation: 'password')
    @admin.save
    @account = FactoryBot.create(:account)
    @service = FactoryBot.create(:service)
    @sub_category = FactoryBot.create(:sub_category, parent_id: @service.id)
    @faq = FactoryBot.create(:question_answer)

    sign_in @admin
  end

  describe "Get#index" do
    it "show all contact requests" do
      get :index
      expect(response).to have_http_status(200)
    end
  end

  describe "Put#edit" do
    let(:params) do {
      "question" => "test question"
    }end
    it "edit company" do
        put :update, params: {id: @faq.id, question_answer: params}
        expect(response).to have_http_status(302)
    end
  end
end