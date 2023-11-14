# frozen_string_literal: true

module BxBlockCategories
  class CategorySerializer < BuilderBase::BaseSerializer
    attributes :id, :name, :description

    attributes :sub_categories do |cat, params|
      if params[:account].present? 
        sub_categories = params[:account].available_sub_categories.where(parent_id: cat.id)
        SubCategorySerializer.new(sub_categories).serializable_hash 
      else
        SubCategorySerializer.new(cat.sub_categories).serializable_hash
      end
    end

  end
end
