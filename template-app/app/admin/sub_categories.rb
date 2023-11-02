ActiveAdmin.register BxBlockCategories::SubCategory, as: "Sub Category" do
    
    permit_params :name, :parent_id, :start_from, :description, :duration, :image

    index do
      selectable_column
      id_column
      column :name
      column :start_from
      column :duration
      column :parent
      column :image do |c|
        c.image.present? ?
        image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : "No Image"
      end
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :name
        f.input :start_from
        f.input :duration
        f.input :description
        f.input :parent
        f.input :image, as: :file, hint: f.object.image.present? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(f.object.image, only_path: true), width: 200, controls: true) : "No Image"
      end
      f.actions
    end
  
    show do
      attributes_table do
        row :name
        row :parent
        row :start_from
        row :duration
        row :description
        row :image do |c|
          c.image.present? ?
          image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : "No Image"
        end
        row :created_at
        row :updated_at
      end
    end
    
  end
  