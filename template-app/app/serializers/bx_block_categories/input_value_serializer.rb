module BxBlockCategories
    class InputValueSerializer < BuilderBase::BaseSerializer
        attributes :id, :input_field_id, :company_input_field_id, :additional_service_id, :user_input, :cost
        
        attributes :input_field do |iv|
            if iv.input_field.present?
                { id: ifd.id, name: ifd.name, field_type: ifd.field_type, section: ifd.section, options: ifd.options, values: ifd.values, multiplier: ifd.multiplier, default_value: ifd.default_value, note: ifd.note, type: "Input Field" }
            elsif iv.company_input_field.present?
                { id: ifd.id, name: ifd.name, field_type: ifd.field_type, section: ifd.section, options: ifd.options, values: ifd.values, multiplier: ifd.multiplier, default_value: ifd.default_value, note: ifd.note, type: "Company Input Field" }
            end
        end
    end
end