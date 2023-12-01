module BxBlockCategories
    class InputFieldSerializer < BuilderBase::BaseSerializer
      attributes :id, :name, :field_type, :options, :values, :multiplier, :default_value, :note, :inputable_id, :inputable_type
    end
end