module BxBlockCategories
    class InputValue < ApplicationRecord
        self.table_name = :input_values

        before_save :save_input_field_data, if: :user_input_changed?

        # validates :additional_service_id, uniqueness: { scope: :company_input_field_id, message: "Input value already attached with this service & inquiry"}
        validate :user_input_value, if: :user_input_changed?
        validate :check_input_field

        belongs_to :input_field, class_name: "BxBlockCategories::InputField", optional: true
        belongs_to :company_input_field, class_name: "BxBlockCategories::CompanyInputField", optional: true
        belongs_to :additional_service, class_name: "BxBlockCategories::AdditionalService"
        
        default_scope { order(created_at: :asc)}
        
        private

        def check_input_field
            if input_field.present? && company_input_field.present?
                errors.add(:input_field, "Input field or company input field, any one should be present "); errors.add(:company_input_field, "Input field or company input field, any one should be present")
            elsif input_field.blank? && company_input_field.blank?
                errors.add(:input_field, "Input field or company input field, should be present"); errors.add(:company_input_field, "Input field or company input field, should be present")
            end
        end

        def user_input_value
            input = input_field.presence || company_input_field
            if input.field_type == "multiple_options" && user_input.present?
                errors.add(:user_input, "invalid") unless input.options.split(", ").include? user_input
            end
        end

        def save_input_field_data
            self.input_field_data = self.input_field.to_json
        end
    end
end
