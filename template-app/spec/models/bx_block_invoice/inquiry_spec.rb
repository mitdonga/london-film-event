require 'rails_helper'
RSpec.describe BxBlockInvoice::Inquiry, type: :model do
  describe "Validations" do
    it { should define_enum_for(:status).with_values(%i[draft pending approved hold rejected]) }
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

end