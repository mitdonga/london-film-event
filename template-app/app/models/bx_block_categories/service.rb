module BxBlockCategories
    class Service < Category

        has_many :sub_categories, class_name: "BxBlockCategories::SubCategory", foreign_key: 'parent_id', dependent: :destroy
        accepts_nested_attributes_for :sub_categories, allow_destroy: true

    end
end