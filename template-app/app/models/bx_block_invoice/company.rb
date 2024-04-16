module BxBlockInvoice
  class Company < ApplicationRecord
    self.table_name = :bx_block_invoice_companies

    after_create :add_company_sub_categories
    after_create :add_company_categories
    after_create :create_company_input_fields

    has_many :accounts, class_name: "AccountBlock::Account"
    has_many :custom_services, class_name: "BxBlockCategories::Category", foreign_key: "company_id", dependent: :destroy

    has_many :company_input_fields, class_name: "BxBlockCategories::CompanyInputField", dependent: :destroy
    accepts_nested_attributes_for :company_input_fields, allow_destroy: true

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
      services = company_categories.includes(:category).order("categories.name").map {|cc| {:company_category_id => cc.id, :service_id => cc.category.id, :service_name => cc.category.name, :has_access => cc.has_access, :service => cc.category}}
      services.map do |s|
        input_fields = company_input_fields.includes(:input_field).where(input_field_id: s[:service].input_fields.ids)
        data = company_sub_categories.joins(:sub_category => :parent).where("categories.id = ?", s[:service_id])
        filtered_data = data.map {|s| {:company_sub_category_id => s.id, :price => s.price, :sub_category_name => s.sub_category.name}}
        s.merge({company_sub_categories: filtered_data, input_fields: input_fields})
      end
    end

    def available_services
      BxBlockCategories::Category.joins(:company_categories)
        .where('company_categories.has_access = true and company_categories.company_id = ? and categories.type = ?', self.id, "Service").distinct
    end

    def available_sub_categories
      service_ids = available_services.pluck(:id)
      BxBlockCategories::SubCategory.joins(company_sub_categories: :sub_category)
        .select("sub_categories.*, company_sub_categories.price AS actual_price")
        .where("sub_categories.parent_id IN (?) and company_sub_categories.company_id = ?", service_ids, self.id).distinct
    end

    def company_admins
      accounts.where(type: "ClientAdmin")
    end

    def company_users
      accounts.where(type: "ClientUser")
    end

    def domain
      self.email.split("@")[1] rescue nil
    end

    def company_inquiries
      user_dis = accounts.ids
      Inquiry.where(user_id: user_dis)
    end

    private

    def create_company_input_fields
      BxBlockCategories::InputField.where(section: "addon").each do |input_field|
        BxBlockCategories::CompanyInputField.create(company_id: self.id, input_field_id: input_field.id, values: input_field.values, multiplier: input_field.multiplier, default_value: input_field.default_value)
      end
    end

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
