# frozen_string_literal: true

module BxBlockCategories
  class CategorySerializer < BuilderBase::BaseSerializer
    attributes :id, :name, :description

    attributes :sub_categories do |cat, params|
      sb_categories = params[:account].present? ? params[:account].available_sub_categories.where(parent_id: cat.id) : cat.sub_categories
      SubCategorySerializer.new(sb_categories).serializable_hash
    end

    attributes :start_from_price do |cat, params|
      params[:account].present? ? params[:account].available_sub_categories.where(parent_id: cat.id).map(&:actual_price).min : cat.sub_categories.pluck(:start_from).min
    end

    attributes :image do |cat|
      cat.image.attached? ?
      Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(cat.image, only_path: true) : ""
    end

  end
end
