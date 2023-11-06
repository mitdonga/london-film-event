# frozen_string_literal: true

module BxBlockCategories
  class SubCategory < BxBlockCategories::ApplicationRecord
    self.table_name = :sub_categories

    after_create :add_company_sub_categories

    has_one_attached :image
    has_and_belongs_to_many :categories, join_table: :categories_sub_categories, dependent: :destroy
    belongs_to :parent, class_name: "BxBlockCategories::Service"
    
    has_many :user_sub_categories, class_name: "BxBlockCategories::UserSubCategory",
      join_table: "user_sub_categoeries", dependent: :destroy
    has_many :accounts, class_name: "AccountBlock::Account", through: :user_sub_categories,
      join_table: "user_sub_categoeries"

    has_many :company_sub_categories, class_name: "BxBlockInvoice::CompanySubCategory", foreign_key: "sub_category_id", dependent: :destroy
    has_many :companies, through: :company_sub_categories

    validates :name, presence: true
    validate :check_parent_categories

    private

    def add_company_sub_categories
      company_ids = BxBlockInvoice::Company.ids
      data = company_ids.map {|c_id| { company_id: c_id, sub_category_id: self.id, price: self.start_from }}
      BxBlockInvoice::CompanySubCategory.create!(data)
    end

    def check_parent_categories
      errors.add(:base, "Please select categories or a parent.") if categories.blank? && parent.blank?
    end
  end
end
