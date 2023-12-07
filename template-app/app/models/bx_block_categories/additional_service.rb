module BxBlockCategories
    class AdditionalService < ApplicationRecord
        self.table_name = :additional_services

        after_create :create_input_values
        before_destroy :check_inquiry_service

        belongs_to :service, class_name: "BxBlockCategories::Service"
        belongs_to :inquiry, class_name: "BxBlockInvoice::Inquiry"

        has_many :input_values, class_name: "BxBlockCategories::InputValue", dependent: :destroy

        validates :service_id, uniqueness: { scope: :inquiry_id, message: "This service is already attached with this inquiry"}

        private

        def check_inquiry_service
            if inquiry&.service == service
                self.errors.add(:base, "You can't delete basic service of this inquiry")
                throw :abort
            end
        end

        def create_input_values
            fields = inquiry.service == service ? service.input_fields : service.input_fields.where(section: "addon")
            fields.each do |f|
                record = input_values.new(input_field_id: f.id)
                record.save!
            end
        end
    end
end
