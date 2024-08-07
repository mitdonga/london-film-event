# frozen_string_literal: true

module BxBlockCategories
  class SubCategory < BxBlockCategories::ApplicationRecord
    self.table_name = :sub_categories

    after_create :add_company_sub_categories

    has_one_attached :image
    validates :image, :content_type => ["jpg", "png", "jpeg", "image/jpg", "image/jpeg", "image/png", "svg", "image/svg+xml"]
    
    has_and_belongs_to_many :categories, join_table: :categories_sub_categories, dependent: :destroy
    belongs_to :parent, class_name: "BxBlockCategories::Service"
    
    has_many :user_sub_categories, class_name: "BxBlockCategories::UserSubCategory",
      join_table: "user_sub_categoeries", dependent: :destroy
    has_many :accounts, class_name: "AccountBlock::Account", through: :user_sub_categories,
      join_table: "user_sub_categoeries"

    has_many :inquiries, class_name: "BxBlockInvoice::Inquiry", foreign_key: "sub_category_id", dependent: :destroy
    has_many :company_sub_categories, class_name: "BxBlockInvoice::CompanySubCategory", foreign_key: "sub_category_id", dependent: :destroy
    has_many :companies, through: :company_sub_categories
    
    has_many :features, class_name: "BxBlockCategories::Feature", foreign_key: "sub_category_id", dependent: :destroy
    accepts_nested_attributes_for :features, allow_destroy: true

    has_many :default_coverages, class_name: "BxBlockCategories::DefaultCoverage", foreign_key: "sub_category_id", dependent: :destroy
    accepts_nested_attributes_for :default_coverages, allow_destroy: true

    has_many :input_fields, as: :inputable, dependent: :destroy

    validates :name, presence: true
    validate :check_parent_categories

    private

    def add_company_sub_categories
      if self.parent.company_id.present?
        BxBlockInvoice::CompanySubCategory.create!({ company_id: self.parent.company_id, sub_category_id: self.id, price: self.start_from })
      else
        company_ids = BxBlockInvoice::Company.ids
        data = company_ids.map {|c_id| { company_id: c_id, sub_category_id: self.id, price: self.start_from }}
        BxBlockInvoice::CompanySubCategory.create!(data)
      end
    end

    def check_parent_categories
      errors.add(:base, "Please select categories or a parent.") if categories.blank? && parent.blank?
    end
  end
end
