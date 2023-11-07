module BxBlockInvoice
  class Company < ApplicationRecord
    self.table_name = :bx_block_invoice_companies

    after_create :add_company_sub_categories

    has_many :company_sub_categories, class_name: "BxBlockInvoice::CompanySubCategory", foreign_key: "company_id", dependent: :destroy
    has_many :sub_categories, through: :company_sub_categories

    validates :name, :email, :phone_number, presence: true

    private

    def add_company_sub_categories
      sub_categories = BxBlockCategories::SubCategory.select(:id, :start_from)
      data = sub_categories.map {|sc| { company_id: self.id, sub_category_id: sc[:id], price: sc[:start_from] }}
      BxBlockInvoice::CompanySubCategory.create!(data)
    end
  end
end
