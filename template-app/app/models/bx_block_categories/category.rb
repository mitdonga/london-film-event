# frozen_string_literal: true

module BxBlockCategories
  class Category < BxBlockCategories::ApplicationRecord
    include ActiveStorageSupport::SupportForBase64
    self.table_name = :categories

    after_create :add_basic_input_fields

    has_one_attached :image
    validates :image, :content_type => ["jpg", "png", "jpeg", "image/jpg", "image/jpeg", "image/png"]
    # has_many :sub_categories, class_name: "BxBlockCategories::SubCategory", foreign_key: 'parent_id', dependent: :destroy
    # accepts_nested_attributes_for :sub_categories, allow_destroy: true
    
    # has_and_belongs_to_many :companies, class_name: "BxBlockInvoice::Company", join_table: :companies_categories
    # accepts_nested_attributes_for :companies, allow_destroy: true

    # attr_accessible :company_ids
    # attr_accessible :company_ids
    # has_and_belongs_to_many :sub_categories,
    #   join_table: :categories_sub_categories, dependent: :destroy

    # has_many :contents, class_name: "BxBlockContentmanagement::Content", dependent: :destroy
    has_many :ctas, class_name: "BxBlockCategories::Cta", dependent: :nullify
    has_many :inquiries, class_name: "BxBlockInvoice::Inquiry", foreign_key: "service_id", dependent: :destroy
    has_many :user_categories, class_name: "BxBlockCategories::UserCategory",
      join_table: "user_categoeries", dependent: :destroy
    has_many :accounts, class_name: "AccountBlock::Account", through: :user_categories,
      join_table: "user_categoeries",  dependent: :destroy

    has_many :company_categories, class_name: "BxBlockInvoice::CompanyCategory", foreign_key: "category_id", dependent: :destroy
    has_many :companies, through: :company_categories

    belongs_to :company, class_name: "BxBlockInvoice::Company", foreign_key: "company_id", optional: true

    has_many :input_fields, as: :inputable, dependent: :destroy
    accepts_nested_attributes_for :input_fields, allow_destroy: true

    validates :name, uniqueness: true, presence: true
    validates :description, presence: true
    validates_uniqueness_of :identifier, allow_blank: true

    enum catalogue_type: %w[all_packages bespoke_packages]
    enum status: %w[unarchived archived]

    def is_custom_service?
      company.present?
    end

    def copy_input_fields(category_id, addons_only=false)
      return unless company.present?
      base_category = Category.find(category_id)
      all_input_fields = base_category.input_fields

      non_addons_input_fields = addons_only ? [] : base_category.input_fields.where.not(section: "addon").order(created_at: :asc)
      non_addons_input_fields.each do |inf|
        atr = inf.attributes.slice("name", "field_type", "options", "values", "multiplier", "default_value", "note", "section")
        self.input_fields.create(atr)
      end

      cmp_inp_filds = BxBlockCategories::CompanyInputField.includes(:input_field).where(input_field_id: all_input_fields.ids, company_id: company.id).order(created_at: :asc)

      cmp_inp_filds.each do |cif|
        inf = cif.input_field
        self.input_fields.create(name: inf.name, field_type: inf.field_type, options: inf.options, note: inf.note, section: inf.section,
                                values: cif.values, multiplier: cif.multiplier, default_value: cif.default_value) if inf.present?
      end
    end

    private

    def add_basic_input_fields
      return if self.is_custom_service?
      ["Client Name", "Company Name", "Event Name", "Location / Venue", "Total Event Budget"].each do |name|
        input_fields.create(name: name, field_type: "text", section: "required_information")
      end
      # ["Event Date"].each do |name|
      #   input_fields.create(name: name, field_type: "calender_select", section: "required_information")
      # end unless 
      if Rails.env != "test"
        ["Event Start Time", "Event End Time"].each do |name|
          input_fields.create(name: name, field_type: "time", section: "required_information")
        end
      end
    end
  end
end
