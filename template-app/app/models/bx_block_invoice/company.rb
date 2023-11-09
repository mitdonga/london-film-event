module BxBlockInvoice
  class Company < ApplicationRecord
    self.table_name = :bx_block_invoice_companies

    after_create :add_company_sub_categories
    after_create :add_company_categories

    has_many :company_sub_categories, class_name: "BxBlockInvoice::CompanySubCategory", foreign_key: "company_id", dependent: :destroy
    has_many :sub_categories, through: :company_sub_categories

    has_many :company_categories, class_name: "BxBlockInvoice::CompanyCategory", foreign_key: "company_id", dependent: :destroy
    has_many :categories, through: :company_categories

    validates :name, :email, :phone_number, presence: true

    def services
      categories
    end

    def sub_categories_with_service
      data = company_sub_categories.map {|csc| csc.attributes.merge({"sub_category"=> csc.sub_category.name, "service"=> csc.service.name})}
      data.group_by {|sc| sc["service"]}
    end

    private

    def add_company_sub_categories
      puts "========== Inside add_company_sub_categories ==========="
      sub_categories = BxBlockCategories::SubCategory.select(:id, :start_from)
      data = sub_categories.map {|sc| { company_id: self.id, sub_category_id: sc[:id], price: sc[:start_from] }}
      BxBlockInvoice::CompanySubCategory.create!(data)
    end

    def add_company_categories
      puts "========== Inside add_company_categories ==========="
      service_ids = BxBlockCategories::Service.ids
      data = service_ids.map {|i| { company_id: self.id, category_id: i}}
      BxBlockInvoice::CompanyCategory.create!(data)
    end
  end
end
