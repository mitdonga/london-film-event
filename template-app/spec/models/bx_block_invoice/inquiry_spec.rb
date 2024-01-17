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
end