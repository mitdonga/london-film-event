ActiveAdmin.register BxBlockCategories::SubCategory, as: "Sub Category" do
    NO_IMAGE = "No Image"
    permit_params :name, :parent_id, :start_from, :description, :duration, :image, :color_theme, features_attributes: [:id, :name, :_destroy], default_coverages_attributes: [:id, :title, :category, :rank, :_destroy]

    index do
      selectable_column
      id_column
      column :name
      column :start_from
      column :duration
      column :parent
      column :color_theme
      column :image do |c|
        c.image.present? ?
        image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : NO_IMAGE
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
        f.input :color_theme, as: :color_picker, palette: ["#594FF5", "#00BFBB", "#FFC500", "#FF5B74", "#BDB9FB", "#99E5E4", "#FFE899", "#FFBDC7", "#DEDCFD", "#CCF2F1", "#FFF4CE", "#FFDEE3"]
        f.input :image, as: :file, hint: f.object.image.present? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(f.object.image, only_path: true), width: 200, controls: true) : NO_IMAGE
        # if f.object.persisted?
          tabs do
            tab "Manage Features" do
              f.inputs do
                f.has_many :features, 
                    heading: 'Manage Features',                    
                    allow_destroy: true,
                    new_record: true,
                    class: 'features_container' do |s|       
                  s.input :name
                end
              end
            end
            tab "Manage Default Coverages" do
              f.inputs do
                f.has_many :default_coverages, 
                    heading: 'Manage Default Coverages',                    
                    allow_destroy: true,
                    new_record: true,
                    class: 'default_coverages_container' do |s|       
                  s.input :title
                  s.input :category
                end
              end
            end
          end
        # end
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
        row :color_theme
        row :image do |c|
          c.image.present? ?
          image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : NO_IMAGE
        end
        row :features do |sb|
          ul do
            sb.features.each do |coverage|
              li "#{coverage.name}", style: 'margin-top: 5px;'
            end
          end
        end
        row :default_coverages do |sb|
          ul do
            sb.default_coverages.each do |coverage|
              li "#{coverage.category}  -  #{coverage.title}", style: 'margin-top: 5px;'
            end
          end
        end
        row :created_at
        row :updated_at
      end
    end
    
  end
  