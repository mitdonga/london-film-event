module BxBlockInvoice
  class CompanySubCategory < ApplicationRecord
    belongs_to :company
    belongs_to :sub_category
  end
end
