module BxBlockCategories   
    class DefaultCoverage < ApplicationRecord
        self.table_name = :default_coverages

        validates :title, :category, presence: true

        belongs_to :sub_category, class_name: "BxBlockCategories::SubCategory"

        enum category: %i[pre_production crew equipment distribution media other]
    end
end