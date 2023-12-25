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

    has_many :user_categories, class_name: "BxBlockCategories::UserCategory",
      join_table: "user_categoeries", dependent: :destroy
    has_many :accounts, class_name: "AccountBlock::Account", through: :user_categories,
      join_table: "user_categoeries",  dependent: :destroy

    has_many :company_categories, class_name: "BxBlockInvoice::CompanyCategory", foreign_key: "category_id", dependent: :destroy
    has_many :companies, through: :company_categories

    has_many :input_fields, as: :inputable
    accepts_nested_attributes_for :input_fields, allow_destroy: true

    validates :name, uniqueness: true, presence: true
    validates :description, presence: true
    validates_uniqueness_of :identifier, allow_blank: true

    enum catalogue_type: %w[all_packages bespoke_packages]
    enum status: %w[unarchived archived]

    private

    def add_basic_input_fields
      ["Client Name", "Company Name", "Event Name"].each do |name|
        input_fields.create(name: name, field_type: "text", section: "required_information")
      end
    end
  end
end
