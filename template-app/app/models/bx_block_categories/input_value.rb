module BxBlockCategories
    class InputValue < ApplicationRecord
        self.table_name = :input_values

        validates :additional_service_id, uniqueness: { scope: :input_field_id, message: "Input value already attached with this service & inquiry"}

        belongs_to :input_field, class_name: "BxBlockCategories::InputField"
        belongs_to :additional_service, class_name: "BxBlockCategories::AdditionalService"
    end
end
