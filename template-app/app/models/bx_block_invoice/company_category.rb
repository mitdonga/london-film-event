module BxBlockInvoice
    class CompanyCategory < ApplicationRecord
        self.table_name = :company_categories

        belongs_to :company, class_name: "BxBlockInvoice::Company", foreign_key: "company_id"
        belongs_to :category, class_name: "BxBlockCategories::Category", foreign_key: "category_id"
    
    end
end
