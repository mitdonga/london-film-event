ActiveAdmin.register BxBlockInvoice::PendingReview, as: 'Pending Review' do

  permit_params :id, :first_name, :last_name, :email, :status, :status_description, :user_id
  actions :all, except: [:new]

  index do
    selectable_column
    id_column
    column 'First Name', :first_name
    column 'Last Name', :last_name
    column 'Email', :email
    column 'Status', :status
    column 'Status Description', :status_description
    actions
  end

  show do
    attributes_table do
      row :user_id
      row :first_name
      row :last_name
      row :email
      row :status, as: :select, collection: BxBlockInvoice::PendingReview.all.map(&:status)
      row :status_description

    end
  end

  form do |f|
    f.inputs 'Pending Review' do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :status
      f.input :status_description, as: :string, input_html: { class: 'status-description' }

      f.actions
    end
  end
end

