module BxBlockCategories
    class AdditionalService < ApplicationRecord
        self.table_name = :additional_services

        after_create :create_input_values

        belongs_to :service, class_name: "BxBlockCategories::Service"
        belongs_to :sub_category, class_name: "BxBlockCategories::SubCategory", optional: true
        belongs_to :inquiry, class_name: "BxBlockInvoice::Inquiry"

        has_many :input_values, class_name: "BxBlockCategories::InputValue", dependent: :destroy

        validates :service_id, uniqueness: { scope: :inquiry_id, message: "This service is already attached with this inquiry"}

        default_scope { where(is_valid: true) }

        def set_prices
            total_addon_price = input_values.pluck(:cost).map(&:to_f).inject(0.0, :+)
            sub_cat_price = BxBlockInvoice::CompanySubCategory.find_by(company_id: company.id, sub_category_id: sub_category.id)&.price || 0
            self.update(addon_price: total_addon_price, sub_category_price: sub_cat_price)
        end

        def company
            inquiry.user.company
        end

        def service_name
            service.name
        end

        # def sub_category
        #     inquiry.sub_category
        # end

        def set_additional_service_sub_category
            w = get_sub_category_name
            as_sub_c = service.sub_categories.where("name ilike ?", "%#{w}%").first
            as_sub_c = service.sub_categories.first unless as_sub_c.present?
            self.update(sub_category: as_sub_c) if as_sub_c.present?
        end

        def get_default_coverage
            sub_category.present? ? BxBlockCategories::DefaultCoverageSerializer.new(sub_category.default_coverages) : nil
        end

        private

        def create_input_values
            set_additional_service_sub_category
            if inquiry.service == service
                fields = service.input_fields.where.not(section: "addon")
                fields.each do |f|
                    record = input_values.new(input_field_id: f.id)
                    record.save!
                end
            end

            input_field_ids = service.input_fields.where(section: "addon").pluck(:id)
            addon_fields = BxBlockCategories::CompanyInputField.where(company_id: company.id, input_field_id: input_field_ids)
            addon_fields.each do |f|
                record = input_values.new(company_input_field_id: f.id)
                record.save!
            end
        end

        def get_sub_category_name
            scn = inquiry.sub_category.name.downcase
            scn.include?("half") ? "half" : scn.include?("full") ? "full" : scn.include?("short") ? "short" : scn.include?("bespoke") ? "bespoke" : scn.include?("multi") ? "multi" : "full"
        end
    end
end
