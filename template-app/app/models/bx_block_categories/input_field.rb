module BxBlockCategories    
    class InputField < BxBlockCategories::ApplicationRecord
        self.table_name = :input_fields

        validates :name, :field_type, :section, presence: true
        validates :name, uniqueness: { case_sensitive: false, scope: :inputable}
        validates :options, presence: true, if: -> { field_type == "multiple_options" }
        validates :default_value, presence: true, if: -> { multiplier.present? }
        validates :options, :values, :multiplier, absence: true, if: -> { field_type == "text" }
        validate  :validate_edge_case

        belongs_to :inputable, polymorphic: true

        before_validation :sanitize_columns

        enum field_type: %i[text multiple_options calender_select]
        enum section: %i[required_information addon]

        private

        def sanitize_columns
            self.options = sanitize_string(self.options) if self.options.present?
            self.values = sanitize_string(self.values) if self.values.present?
            self.multiplier = sanitize_string(self.multiplier) if self.multiplier.present?
        end

        def sanitize_string(str)
            return unless str.present?
            str.to_s.split(",").select {|e| e.present?}.map {|e| e.strip}.join(", ")
        end

        def validate_edge_case
            if field_type == "multiple_options" || field_type == "calender_select"
                if values.blank? && multiplier.blank?
                    errors.add(:values, "Values or multiplier must be present")
                    errors.add(:multiplier, "Multiplier or Values must be present")
                    return
                elsif values.present? && multiplier.present?
                    errors.add(:values, "Values and multiplier can't be present at a time")
                    errors.add(:multiplier, "Multiplier and values can't be present at a time")
                    return
                elsif values.present? || multiplier.present?
                    entered_values = values.presence || multiplier
                    entered_values = entered_values.split(",").select {|e| e.present?}
                    entered_values.each do |e|
                        unless /\A\d+(\.\d+)?\z/.match?(e.strip) || e.strip.downcase == "speak to expert"
                            errors.add(:values, "Invalid values, please enter comma separated numeric value or 'Speak to expert'") if values.present?
                            errors.add(:multiplier, "Invalid multiplier, please enter comma separated numeric multiplier or 'Speak to expert'") if multiplier.present?
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