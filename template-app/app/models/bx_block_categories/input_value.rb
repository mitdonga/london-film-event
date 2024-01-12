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

        def current_input_field
            input_field.presence || company_input_field
        end

        def formatted_data
            result = {}
            field = current_input_field
            if field.field_type == "multiple_options"
                options = field.options.split(", ")
                if field.values.present?
                    values = field.values&.split(", ")
                    options.each_with_index do |op, index|
                        result[op] = values[index]
                    end
                elsif
                    values = field.multiplier&.split(", ")
                    options.each_with_index do |op, index|
                        result[op] = values[index] =~ /\A[-+]?\d*\.?\d+\Z/ ? values[index].to_f : "Speak to expert"
                    end
                end
            end
            return result
        end

        def calculate_cost
            unless self.user_input.present?
                self.update(cost: 0, note: "User input is null")
                return
            end
            field = current_input_field
            data = field.attributes
            data["user_input"] = self.user_input
            self.update(input_field_data: data)
            if field.field_type == "multiple_options"
                options = field.options.split(", ")
                input_index = options.index(self.user_input)
                if field.values.present?
                    values = field.values.split(", ")
                    input_cost = values.at(input_index)
                    if input_cost.downcase.include?("expert")
                        errors.add(:cost, "invalid, Speak to expert") 
                    else
                        self.update(cost: input_cost.to_f)
                    end
                elsif field.multiplier.present?
                    multiplier = field.multiplier.split(", ")
                    input_cost = multiplier.at(input_index)
                    if input_cost.downcase.include?("expert")
                        errors.add(:cost, "invalid, Speak to expert") 
                    else
                        input_cost = input_cost.to_f * field.default_value.to_f
                        self.update(cost: input_cost.to_f)
                    end
                end
            elsif field.field_type == "calender_select" && field.name.downcase == "event date"
                options = field.options.split(", ")
                event_date = self.user_input.to_date

                if (event_date - Date.today).to_i/7.0
                    BxBlockInvoice::EventDateMailer.date_mail(event_date).deliver_now
                end

                week_left = (event_date - Date.today).to_i/7.0
                final_index = nil
                options.each_with_index do |option, index|
                    match = option.match(/(\d+)\s?\+/)
                    if match.present? && match[0].to_i <= week_left
                        final_index = index 
                        break
                    end
                    match = option.match(/<\s?(\d+)/)
                    if match.present? && match[1].to_i >= week_left
                        final_index = index 
                        break
                    end
                    match = option.match(/(\d+)\s?-\s?(\d+)/)
                    if match.present? && match[1].to_i <= week_left && match[2].to_i >= week_left
                        final_index = index 
                        break
                    end
                end
                if field.values.present?
                    values = field.values.split(", ")
                    input_cost = values.at(final_index)
                    if input_cost.downcase.include?("expert")
                        errors.add(:cost, "invalid, Speak to expert") 
                    else
                        self.update(cost: input_cost.to_f)
                    end
                elsif field.multiplier.present?
                    multiplier = field.multiplier.split(", ")
                    input_cost = multiplier.at(final_index)
                    if input_cost.downcase.include?("expert")
                        errors.add(:cost, "invalid, Speak to expert") 
                    else
                        input_cost = input_cost.to_f * field.default_value.to_f
                        self.update(cost: input_cost.to_f)
                    end
                end
            end
        end
        
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
