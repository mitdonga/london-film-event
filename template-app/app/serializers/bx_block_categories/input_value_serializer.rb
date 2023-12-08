module BxBlockCategories
    class InputValueSerializer < BuilderBase::BaseSerializer
        attributes :id, :input_field_id, :additional_service_id, :user_input, :cost
        
        attributes :input_field do |iv|
            ifd = iv.input_field
            { id: ifd.id, name: ifd.name, field_type: ifd.field_type, section: ifd.section, options: ifd.options, values: ifd.values, multiplier: ifd.multiplier, default_value: ifd.default_value, note: ifd.note }
        end
    end
end