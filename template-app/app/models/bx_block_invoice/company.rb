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

    def services_sub_categories_data
      services = company_categories.includes(:category).order(:id).map {|cc| {:company_category_id => cc.id, :service_id => cc.category.id, :service_name => cc.category.name, :has_access => cc.has_access}}
      services.map do |s|
        data = company_sub_categories.joins(:sub_category => :parent).where("categories.id = ?", s[:service_id])
        filtered_data = data.map {|s| {:company_sub_category_id => s.id, :price => s.price, :sub_category_name => s.sub_category.name}}
        s.merge({company_sub_categories: filtered_data})
      end
    end

    private

    def add_company_sub_categories
      sub_categories = BxBlockCategories::SubCategory.select(:id, :start_from)
      data = sub_categories.map {|sc| { company_id: self.id, sub_category_id: sc[:id], price: sc[:start_from] }}
      BxBlockInvoice::CompanySubCategory.create!(data)
    end

    def add_company_categories
      service_ids = BxBlockCategories::Service.ids
      data = service_ids.map {|i| { company_id: self.id, category_id: i}}
      BxBlockInvoice::CompanyCategory.create!(data)
    end
  end
end
