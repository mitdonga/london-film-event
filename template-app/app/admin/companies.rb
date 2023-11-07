ActiveAdmin.register BxBlockInvoice::Company, as: "Company" do

  # permit_params :name, :address, :city, :zip_code, :phone_number, :email, company_sub_categories_attributes: [:id, :price]
  permit_params :all

  index do
    selectable_column
    id_column
    column :name
    column :address
    column :city
    column :zip_code
    column :phone_number
    column :email
    actions
  end

  show do
    attributes_table do
      row :name
      row :address
      row :city
      row :zip_code
      row :phone_number
      row :email
    end
  end

  form do |f|
    f.inputs do
      f.inputs :name
      f.inputs :address
      f.inputs :city
      f.inputs :zip_code
      f.inputs :phone_number
      f.inputs :email
      if f.object.persisted?
        f.inputs "Manage Sub Category Prices" do
          tabs do
            f.object.sub_categories_with_service.each do |service, sub_categories|
              tab "#{service}" do
                sub_categories.each do |sub_category_data|
                  f.input "company_sub_categories[#{sub_category_data['id']}][id]",  input_html: { value: sub_category_data['id'] }, as: :hidden
                  f.input "company_sub_categories[#{sub_category_data['id']}][price]", label: "#{sub_category_data['sub_category']} Price", input_html: { value: sub_category_data['price'], type: 'number', step: '1', min: '1', required: true  }
                end
              end
            end
          end
        end
      end
    end

    f.actions
  end
end
