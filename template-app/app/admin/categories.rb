ActiveAdmin.register BxBlockCategories::Category, as: "Category" do
    
    permit_params :name, :description, :start_from, :catalogue_type

    index do
      selectable_column
      id_column
      column :name
      column :start_from
      column :catalogue_type
      actions
    end
  
    form do |f|
      f.inputs do
        f.input :name
        f.input :description
        f.input :start_from
        f.input :catalogue_type
      end
      f.actions
    end
  
    show do
      attributes_table do
        row :name
        row :catalogue_type
        row :description
        row :start_from
        row :created_at
        row :updated_at
      end
    end
    
  end
  