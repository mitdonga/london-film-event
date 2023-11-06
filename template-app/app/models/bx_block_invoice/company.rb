module BxBlockInvoice
  class Company < ApplicationRecord
    self.table_name = :bx_block_invoice_companies

    # has_and_belongs_to_many :categories, class_name: "BxBlockCategories::Category", join_table: :companies_categories


    validates :name, :email, presence: true
  end
end
