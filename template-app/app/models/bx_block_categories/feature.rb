module BxBlockCategories
    class Feature < BxBlockCategories::ApplicationRecord
        self.table_name = :features

        belongs_to :sub_category, class_name: "BxBlockCategories::SubCategory"
        
        validates :name, presence: true
        validates :name, length: { in: 5..50 }
        

    end
end
