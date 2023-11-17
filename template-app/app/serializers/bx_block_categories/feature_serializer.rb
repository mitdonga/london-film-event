module BxBlockCategories
    class FeatureSerializer < BuilderBase::BaseSerializer
      attributes :id, :name, :sub_category_id
    end
end