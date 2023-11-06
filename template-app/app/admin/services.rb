ActiveAdmin.register BxBlockCategories::Service, as: "Service" do
  NO_IMAGE = "No Image"
  permit_params :name, :description, :start_from, :catalogue_type, :status, :image, company_ids: [], sub_categories_attributes: [:id, :name, :start_from, :duration, :image, :_destroy]

  index do
    selectable_column
    id_column
    column :name
    column :image do |c|
      c.image.present? ?
      image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : NO_IMAGE
    end
    column :sub_categories do |c|
      c.sub_categories.pluck(:name)
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      # f.input :company_ids, as: :selected_list, label: "Companies"
      f.input :image, as: :file, hint: f.object.image.present? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(f.object.image, only_path: true), width: 200, controls: true) : NO_IMAGE
      if f.object.persisted?
        f.inputs do
          f.has_many :sub_categories, 
              heading: 'Manage Sub Categories',                    
              allow_destroy: true,
              new_record: true,
              class: 'sub_categories_container' do |s|       
            s.input :name
            s.input :start_from, label: "Default Price"
            s.input :duration
            s.input :image, as: :file, hint: s.object.image.present? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(s.object.image, only_path: true), width: 100, controls: true) : NO_IMAGE
          end
        end
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :image do |c|
        c.image.present? ?
        image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : NO_IMAGE
      end
      row :sub_categories do |c|
        c.sub_categories.pluck(:name)
      end
      row :created_at
      row :updated_at
    end
  end
  
end