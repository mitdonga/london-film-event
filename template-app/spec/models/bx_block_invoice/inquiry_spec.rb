require 'rails_helper'
RSpec.describe BxBlockInvoice::Inquiry, type: :model do
  # include_context "setup data"
  before do
		@company = FactoryBot.create(:company)
		@client_admin = FactoryBot.create(:admin_account, company_id: @company.id)
  end

  describe "Validations" do
    it { should define_enum_for(:status).with_values(%i[unsaved draft pending approved hold rejected]) }
  end

  describe "Callbacks" do
    it { should callback(:check_service_and_sub_category).before(:validation).on(:create) }
    it { should callback(:create_additional_service).after(:create) }
    it { should callback(:send_email_from_lf).after(:update) }
  end

  describe "send_email_from_lf" do
    let!(:user) { FactoryBot.create(:account) }
    let!(:service) { FactoryBot.create(:service) }
    let!(:sub_category) { FactoryBot.create(:sub_category, parent_id: service.id) }
    let!(:inquiry) { FactoryBot.create(:inquiry, user_id: user.id, service_id: service.id, sub_category_id: sub_category.id ) }
    

    it "should send email" do
        expect(BxBlockContactUs::ContactMailer).to receive(:email_from_lf).and_return(double(deliver_now: true))
        inquiry.send_email_from_lf
    end

    context 'for client user' do
        let!(:admin_user) { FactoryBot.create(:admin_account) }
        let!(:new_user) { FactoryBot.create(:user_account, client_admin_id: admin_user.id) }
        let!(:new_inquiry) { FactoryBot.create(:inquiry, user_id: new_user.id, service_id: service.id, sub_category_id: sub_category.id ) }
        it "should send email to client user" do
            expect(BxBlockContactUs::ContactMailer).to receive(:email_from_lf).and_return(double(deliver_now: true))
            inquiry.send_email_from_lf
        end
    end
  end

  describe "Bespoke validation" do
    it "raise error for bespoke inquiry" do
      bspk_service = FactoryBot.create(:service, name: "Bespoke Request")
      expect { FactoryBot.create(:inquiry, user_id: @client_admin.id, service_id: bspk_service.id, sub_category_id: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "create bespoke inquiry" do
		  bspk_service = FactoryBot.create(:service, name: "Bespoke Request")
      FactoryBot.create(:sub_category, name: "Bespoke Request", parent_id: bspk_service.id)

		  service = FactoryBot.create(:service, name: "Av package")
      sbc = FactoryBot.create(:sub_category, name: "Bespoke - Multi Day", parent_id: service.id)

      bspk_inquiry = FactoryBot.create(:inquiry, user_id: @client_admin.id, service_id: bspk_service.id, sub_category_id: nil)
      inquiry = FactoryBot.create(:inquiry, user_id: @client_admin.id, service_id: service.id, sub_category_id: sbc.id)

      assert_equal bspk_inquiry.is_bespoke, true
      assert_equal inquiry.is_bespoke, true
    end
  end

end