module BxBlockCategories    
    class CompanyInputField < BxBlockCategories::ApplicationRecord
        self.table_name = :company_input_fields

        before_validation :sanitize_columns

        validates :company_id, uniqueness: { scope: :input_field_id, message: "Input value already attached with this company"}
        validate :check_edge_case

        belongs_to :company, class_name: "BxBlockInvoice::Company"
        belongs_to :input_field, class_name: "BxBlockCategories::InputField"

        def options
            input_field.options
        end

        def name
            input_field.name
        end

        def field_type
            input_field.field_type
        end

        def section
            input_field.section
        end

        private

        def check_edge_case
            errors.add(:values, "Invalid, should provide #{inputs_size(input_field.values)} values")                if input_field.values.present? && inputs_size(input_field.values) != inputs_size(self.values)
            errors.add(:multiplier, "Invalid, should provide #{inputs_size(input_field.multiplier)} multipliers")   if input_field.multiplier.present? && inputs_size(input_field.values) != inputs_size(self.values)
            errors.add(:default_value, "Must present")                                                              if input_field.default_value.present? && !self.default_value.present?
            errors.add(:values, "Must blank")                                                                       if input_field.values.blank? && self.values.present?
            errors.add(:multiplier, "Must blank")                                                                   if input_field.multiplier.blank? && self.multiplier.present?
            errors.add(:default_value, "Must blank")                                                                if input_field.default_value.blank? && self.default_value.present?
        end

        def sanitize_columns
            self.values = sanitize_string(self.values) if self.values.present?
            self.multiplier = sanitize_string(self.multiplier) if self.multiplier.present?
        end

        def sanitize_string(str)
            return unless str.present?
            str.to_s.split(",").select {|e| e.present?}.map {|e| e.strip}.join(", ")
        end

        def inputs_size(str)
            return unless str.present?
            str.to_s.split(",").size
        end
    end
end
