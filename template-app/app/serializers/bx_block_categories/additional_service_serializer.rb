module BxBlockCategories
    class AdditionalServiceSerializer < BuilderBase::BaseSerializer

        attributes :id, :service_id, :inquiry_id, :is_valid

        attributes :service_name do |as|
            as.service&.name
        end

        attributes :input_values, if: proc { |as, params| params[:extra]} do |as|
            input_values = as.input_values
            InputValueSerializer.new(input_values).serializable_hash
        end

        attributes :default_coverages, if: proc { |as, params| params[:extra]} do |as, params|
            params[:manage_additional_service].present? ? params[:manage_additional_service].get_default_coverage(as)&.serializable_hash : nil
        end
    end
end