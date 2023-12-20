module BxBlockCategories    
    class CompanyInputField < BxBlockCategories::ApplicationRecord
        self.table_name = :company_input_fields

        validates :company_id, uniqueness: { scope: :input_field_id, message: "Input value already attached with this company"}

        belongs_to :company, class_name: "BxBlockInvoice::Company"
        belongs_to :input_field, class_name: "BxBlockCategories::InputField"

        private

        def sanitize_columns
            self.values = sanitize_string(self.values) if self.values.present?
            self.multiplier = sanitize_string(self.multiplier) if self.multiplier.present?
        end

        def sanitize_string(str)
            return unless str.present?
            str.to_s.split(",").select {|e| e.present?}.map {|e| e.strip}.join(", ")
        end
    end
end
