module BxBlockInvoice
  class CompanySubCategory < ApplicationRecord

    self.table_name = :company_sub_categories

    belongs_to :company, class_name: "BxBlockInvoice::Company", foreign_key: "company_id"
    belongs_to :sub_category, class_name: "BxBlockCategories::SubCategory", foreign_key: "sub_category_id"

    validates :company_id, uniqueness: { scope: :sub_category_id, message: "This company and sub category already associated" }
    validates :company_id, :sub_category_id, :price, presence: true
    
    def service
      sub_category.parent
    end
  end
end
