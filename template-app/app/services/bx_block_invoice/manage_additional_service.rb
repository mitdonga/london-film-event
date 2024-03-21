module BxBlockInvoice
    class ManageAdditionalService
        def initialize(inquiry)
            @inquiry = inquiry
            @base_service = @inquiry.service
            @base_sub_category = @inquiry.sub_category
        end

        def get_default_coverage(additional_service)
            return nil unless additional_service.present?
            w = get_sub_category_name
            as_sub_c = additional_service.service.sub_categories.where("name ilike ?", "%#{w}%").first
            as_sub_c = additional_service.service.sub_categories.first unless as_sub_c.present?
            as_sub_c.present? ? BxBlockCategories::DefaultCoverageSerializer.new(as_sub_c.default_coverages) : nil
        end

        private

        def get_sub_category_name
            scn = @base_sub_category.name.downcase
            scn.include?("half") ? "half" : scn.include?("full") ? "full" : scn.include?("short") ? "short" : scn.include?("bespoke") ? "bespoke" : scn.include?("multi") ? "multi" : "full"
            
        end
    end
end