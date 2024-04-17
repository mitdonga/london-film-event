ActiveAdmin.register BxBlockCategories::Service, as: "Bespoke Service" do
    NO_IMAGE = "No Image"
    NO_FILE  = "No File"
    scope("Service", default: true) { |service| service.where.not(company_id: nil).order(created_at: :desc) }
    permit_params :name, :description, :start_from, :catalogue_type, :status, :image, :company_id,
                  company_ids: [], sub_categories_attributes: [:id, :name, :start_from, :duration, :color_theme, :image, :_destroy],
                  input_fields_attributes: [:id, :name, :field_type, :options, :section, :values, :multiplier, :default_value, :note, :_destroy]
    menu parent: "Content Management"
    index do
      selectable_column
      id_column
      column :name
      column :company
      column :image do |c|
        c.image.present? ?
        image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : NO_IMAGE
      end
      column :sub_categories do |c|
        c.sub_categories.each {|sc| link_to sc.name, admin_sub_category_path(sc)}
      end
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :name; f.input :description, as: :text, input_html: { rows: 10 }
        f.input :image, as: :file, hint: f.object.image.present? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(f.object.image, only_path: true), width: 200, controls: true) : NO_IMAGE
        f.input :company_id, as: :select, collection: BxBlockInvoice::Company.all.map {|a| [a.name, a.id]}
        if f.object.persisted?
          tabs do
            tab "Manage Input Fields" do
              f.inputs do
                f.has_many :input_fields, 
                    heading: 'Manage Input Fields',                    
                    allow_destroy: true,
                    new_record: true,
                    class: 'input_fields_container' do |s|       
                  s.input :name; s.input :field_type; s.input :section
                  s.input :options, placeholder: "Enter comma (,) separated options"
                  s.input :values, placeholder: "Enter comma (,) separated values"
                  s.input :multiplier, placeholder: "Enter comma (,) separated multiplier"
                  s.input :default_value; s.input :note
                end
              end
            end
            tab "Manage Sub Categories" do
              f.inputs do
                f.has_many :sub_categories, 
                    heading: 'Manage Sub Categories',                    
                    allow_destroy: true,
                    new_record: true,
                    class: 'sub_categories_container' do |s|       
                  s.input :name; s.input :start_from, label: "Default Price"; s.input :duration
                  s.input :image, as: :file, hint: s.object.image.present? ? image_tag(Rails.application.routes.url_helpers.rails_blob_url(s.object.image, only_path: true), width: 100, controls: true) : NO_IMAGE
                end
              end
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
        row :company
        row :image do |c|
          c.image.present? ?
          image_tag(Rails.application.routes.url_helpers.rails_blob_url(c.image, only_path: true), width: 100, controls: true) : NO_IMAGE
        end
        row :sub_categories do |c|
          c.sub_categories.each {|sc| link_to sc.name, admin_sub_category_path(sc)}
        end
        row :created_at
        row :updated_at
      end
  
      panel "Sub Categories" do
        table_for resource.sub_categories do
          column :name do |sc|
            link_to sc.name, admin_sub_category_path(sc)
          end
          column :start_from, label: "Default Price"
          column :duration
          column :image do |sc|
            sc.image.present? ?
            image_tag(Rails.application.routes.url_helpers.rails_blob_url(sc.image, only_path: true), width: 100, controls: true) : NO_IMAGE
          end
        end
      end
  
      panel "Input Fields" do
        table_for resource.input_fields do
          column :name
          column :field_type
          column :section
          column :options
          column :values
          column :multiplier
          column :default_value
          column :note
        end
      end
  
    end
    
  end