# frozen_string_literal: true

module BxBlockCategories
  class SubCategorySerializer < BuilderBase::BaseSerializer
    attributes :id, :name, :start_from, :duration, :parent_id

    attribute :actual_price do |sc|
      sc.actual_price rescue nil
    end

    attribute :category_id do |sc|; sc.parent_id; end
    
  end
end
