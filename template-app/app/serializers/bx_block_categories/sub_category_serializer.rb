# frozen_string_literal: true

module BxBlockCategories
  class SubCategorySerializer < BuilderBase::BaseSerializer
    attributes :id, :name, :start_from, :duration, :parent_id

    attribute :actual_price do |sc|
      sc.actual_price rescue nil
    end

    attribute :category_id do |sc|; sc.parent_id; end

    attributes :image do |sc|
      sc.image.attached? ?
      Rails.application.config.base_url + Rails.application.routes.url_helpers.rails_blob_url(sc.image, only_path: true) : ""
    end

    attributes :features do |sc|
      BxBlockCategories::FeatureSerializer.new(sc.features)
    end

  end
end
