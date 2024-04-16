module BxBlockCategories
    class Service < Category

        after_create :add_company_categories

        has_many :sub_categories, class_name: "BxBlockCategories::SubCategory", foreign_key: 'parent_id', dependent: :destroy
        accepts_nested_attributes_for :sub_categories, allow_destroy: true
        
        has_many :inquiries, class_name: "BxBlockInvoice::Inquiry"
        has_many :additional_services, class_name: "BxBlockCategories::AdditionalService"

        def add_company_categories
            if self.company_id.present?
                BxBlockInvoice::CompanyCategory.create!({company_id: self.company_id, category_id: self.id})
            else
                company_ids = BxBlockInvoice::Company.ids
                data = company_ids.map {|id| {company_id: id, category_id: self.id}}
                BxBlockInvoice::CompanyCategory.create!(data)
            end
        end

    end
end