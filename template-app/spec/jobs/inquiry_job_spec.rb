require 'rails_helper'

RSpec.describe BxBlockInvoice::InquiryJob, type: :job do
    include_context "setup data"
    before do
        3.times do
            i = FactoryBot.create(:inquiry, user_id: @client_user_1.id, status: "unsaved", service_id: @service_1.id, sub_category_id: @service_1.sub_categories.first.id)
            i.update(created_at: Time.now - 40.hours, updated_at: Time.now - 40.hours)

            i2 = FactoryBot.create(:inquiry, user_id: @client_user_1.id, status: "unsaved", service_id: @service_2.id, sub_category_id: @service_2.sub_categories.first.id)
            i2.update(created_at: Time.now - 20.hours, updated_at: Time.now - 20.hours)
        end
    end
    describe "#perform" do
        it "removes unsaved inquiries older than 30 hours" do
            expect(BxBlockInvoice::Inquiry.where(status: "unsaved").count).to eq(6)
            expect {
                BxBlockInvoice::InquiryJob.perform_now
            }.to change { BxBlockInvoice::Inquiry.where(status: "unsaved").count }.by(-3)

            expect(BxBlockInvoice::Inquiry.where(status: "unsaved").count).to eq(3)
        end
    end
end