module BxBlockCategories
    class AdditionalServiceSerializer < BuilderBase::BaseSerializer

        attributes :id, :service_id, :inquiry_id

        attributes :service_name do |as|
            as.service.name
        end

        attributes :input_values, if: proc { |as, params| params[:extra]} do |as|
            input_values = as.input_values
            InputValueSerializer.new(input_values).serializable_hash
        end
    end
end