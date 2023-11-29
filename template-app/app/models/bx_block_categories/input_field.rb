module BxBlockCategories    
    class InputField < BxBlockCategories::ApplicationRecord
        self.table_name = :input_fields

        validates :name, :field_type, presence: true
        validates :name, uniqueness: { case_sensitive: false, scope: :inputable }
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
                    return
                elsif values.present? && multiplier.present?
                    errors.add(:values, "Values and multiplier can't be present at a time for multiple options field")
                    errors.add(:multiplier, "Multiplier and values can't be present at a time for multiple options field")
                    return
                elsif values.present? || multiplier.present?
                    entered_values = values.presence || multiplier
                    entered_values = entered_values.split(",").select {|e| e.present?}
                    entered_values.each do |e|
                        unless /\A\d+(\.\d+)?\z/.match?(e.strip)
                            errors.add(:values, "Invalid values, please enter comma separated numeric value") if values.present?
                            errors.add(:multiplier, "Invalid multiplier, please enter comma separated numeric multiplier") if multiplier.present?
                            return
                        end
                    end
                    return unless options.present?
                    c1 = entered_values&.size || 0
                    filtered_options = options.split(",").select {|e| e.present?}
                    c2 = filtered_options&.size || 0
                    if c2 < 2
                        errors.add(:options, "Options must be greater than 1") if options.present?
                        return
                    elsif c1 != c2
                        errors.add(:values, "Values count must be equal to options count, you entered #{c2} options but values count is #{c1}") if values.present?
                        errors.add(:multiplier, "Multiplier count must be equal to options count, you entered #{c2} options but multiplier count is #{c1}") if multiplier.present?
                        return
                    end
                end
            end
        end
    end
end