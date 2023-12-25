module BxBlockCategories
    class AdditionalService < ApplicationRecord
        self.table_name = :additional_services

        after_create :create_input_values

        belongs_to :service, class_name: "BxBlockCategories::Service"
        belongs_to :inquiry, class_name: "BxBlockInvoice::Inquiry"

        has_many :input_values, class_name: "BxBlockCategories::InputValue", dependent: :destroy

        validates :service_id, uniqueness: { scope: :inquiry_id, message: "This service is already attached with this inquiry"}

        default_scope { where(is_valid: true) }

        def company
            inquiry.user.company
        end

        def sub_category
            inquiry.sub_category
        end
        
        private

        def create_input_values
            if inquiry.service == service
                fields = service.input_fields.where(section: "required_information")
                fields.each do |f|
                    record = input_values.new(input_field_id: f.id)
                    record.save!
                end
            end

            input_field_ids = service.input_fields.where(section: "addon").pluck(:id)
            addon_fields = BxBlockCategories::CompanyInputField.where(company_id: company.id, input_field_id: input_field_ids)
            addon_fields.each do |f|
                record = input_values.new(company_input_field_id: f.id)
                record.save!
            end
        end
    end
end
