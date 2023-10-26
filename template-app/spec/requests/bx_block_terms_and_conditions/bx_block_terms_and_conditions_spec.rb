require 'rails_helper'
require 'spec_helper'
require 'factory_bot'


RSpec.describe "BxBlockTermsAndConditions::TermsAndConditions", type: :request do

  before do 
    @terms = FactoryBot.create(:term)
    @terms_2 = FactoryBot.create(:term)
  end

  describe '#index' do

    it "should return all terms and conditions" do
      get "/bx_block_terms_and_conditions/terms_and_conditions"
      data = JSON.parse(response.body)
      expect(response).to have_http_status(200)
      expect(data["data"].size).to eq(2)
    end

  end

end