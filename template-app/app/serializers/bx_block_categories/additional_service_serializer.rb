module BxBlockCategories
    class AdditionalServiceSerializer < BuilderBase::BaseSerializer

        attributes :id, :service_id, :inquiry_id, :is_valid, :sub_category_price, :addon_price

        attributes :service_name do |as|
            as.service&.name
        end

        attributes :input_values, if: proc { |as, params| params[:extra]} do |as|
            input_values = as.input_values
            InputValueSerializer.new(input_values).serializable_hash
        end

        attributes :default_coverages, if: proc { |as, params| params[:extra]} do |as, params|
            as.get_default_coverage
        end
    end
end