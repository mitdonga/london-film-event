module BxBlockCategories    
    class InputField < BxBlockCategories::ApplicationRecord
        self.table_name = :input_fields

        validates :name, :field_type, presence: true
        validates :options, presence: true, if: -> { field_type == "multiple_options" }
        validates :options, :values, :multiplier, absence: true, if: -> { field_type == "text" }
        validate  :validate_edge_case

        belongs_to :inputable, polymorphic: true

        enum field_type: %i[text multiple_options calender_select]

        private

        def validate_edge_case
            if field_type == "multiple_options"
                if values.blank? && multiplier.blank?
                    errors.add(:values, "Values or multiplier must be present for multiple options field")
                    errors.add(:multiplier, "Multiplier or Values must be present for multiple options field")
                elsif values.present? && multiplier.present?
                    errors.add(:values, "Values and multiplier can't be present at a time for multiple options field")
                    errors.add(:multiplier, "Multiplier and values can't be present at a time for multiple options field")
                elsif values.present? || multiplier.present?
                    entered_values = values.presence || multiplier
                    entered_values = entered_values.split(",")
                    entered_values.each do |e|
                        unless /\A\d+\z/.match?(e.strip)
                            errors.add(:values, "Invalid values, please enter comma separated numeric value") if values.present?
                            errors.add(:multiplier, "Invalid multiplier, please enter comma separated numeric multiplier") if multiplier.present?
                            break
                        end
                    end
                end
                if options.present? && (values.present? || multiplier.present?)
                    entered_options = options.split(",").size
                    selected_values = values.split(",")&.size || multiplier.split(",").size
                end
            end
        end
    end
end