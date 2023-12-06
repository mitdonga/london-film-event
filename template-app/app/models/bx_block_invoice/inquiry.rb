module BxBlockInvoice
    class Inquiry < ApplicationRecord
        self.table_name = :inquiries

        belongs_to :user, class_name: "AccountBlock::Account"
        belongs_to :service, class_name: "BxBlockCategories::Service"
        belongs_to :sub_category, class_name: "BxBlockCategories::SubCategory"

        enum status: %i[draft pending approved]
    end
end
