# frozen_string_literal: true

module BxBlockCategories
  class Category < BxBlockCategories::ApplicationRecord
    include ActiveStorageSupport::SupportForBase64
    self.table_name = :categories

    has_one_attached :image
    # has_one_base64_attached :light_icon_active
    # has_one_base64_attached :light_icon_inactive
    # has_one_base64_attached :dark_icon
    # has_one_base64_attached :dark_icon_active
    # has_one_base64_attached :dark_icon_inactive

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

    validates :name, uniqueness: true, presence: true
    validates :description, presence: true
    validates_uniqueness_of :identifier, allow_blank: true

    enum catalogue_type: %w[all_packages bespoke_packages]
    enum status: %w[unarchived archived]
  end
end
