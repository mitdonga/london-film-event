ActiveAdmin.register BxBlockCategories::Category, as: "Category" do
    
    permit_params :name, :description, :start_from, :catalogue_type, :status, :image, sub_categories_attributes: [:id, :name, :start_from, :duration, :image, :_destroy]

    index do
      selectable_column
      id_column
      column :name
      column :start_from
      column :catalogue_type
      column :status
      column :image do |c|
        c.image.present? ?
        image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : "No Image"
      end
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :name
        f.input :description
        f.input :start_from
        f.input :catalogue_type
        f.input :status
        f.input :image, as: :file, hint: f.object.image.present? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(f.object.image, only_path: true), width: 200, controls: true) : "No Image"
        # f.inputs do
        #   f.has_many :sub_categories, 
        #       heading: 'Manage Sub Categories',                    
        #       allow_destroy: true,
        #       new_record: true,
        #       class: 'sub_categories_container' do |s|       
        #     s.input :name
        #     s.input :start_from
        #     s.input :duration
        #     s.input :image, as: :file, hint: s.object.image.present? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(s.object.image, only_path: true), width: 100, controls: true) : "No Image"
        #   end
        # end
      end
      f.actions
    end
  
    show do
      attributes_table do
        row :name
        row :catalogue_type
        row :description
        row :start_from
        row :status
        row :image do |c|
          c.image.present? ?
          image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : "No Image"
        end
        row :created_at
        row :updated_at
      end
    end
    
  end
  