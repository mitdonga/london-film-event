module BxBlockCategories
    class InputValue < ApplicationRecord
        self.table_name = :input_values

        before_save :save_input_field_data, if: :user_input_changed?

        validates :additional_service_id, uniqueness: { scope: :input_field_id, message: "Input value already attached with this service & inquiry"}
        validate :user_input_value, if: :user_input_changed?

        belongs_to :input_field, class_name: "BxBlockCategories::InputField"
        belongs_to :additional_service, class_name: "BxBlockCategories::AdditionalService"
        
        private

        def user_input_value
            input = input_field
            if input.multiple_options? && user_input.present?
                errors.add(:user_input, "invalid") unless input.options.split(", ").include? user_input
            end
        end

        def save_input_field_data
            self.input_field_data = self.input_field.to_json
        end
    end
end
