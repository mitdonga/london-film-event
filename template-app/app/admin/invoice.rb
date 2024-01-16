ActiveAdmin.register BxBlockInvoice::Inquiry, as: 'Pending Reviews' do

  permit_params :id, :first_name, :status, :status_description, :last_name, :user_type, :email, :service, :sub_category, :lf_admin_email
  actions :all, except: [:new]

  index do
    selectable_column
    id_column
    column 'User Id', :id do |inq|
      inq.user.id
    end
    column 'First Name', :first_name do |inq|
      inq.user.first_name
    end
    column 'Last Name', :last_name do |inq|
      inq.user.last_name
    end
    column 'Email', :email do |inq|
      inq.user.email
    end
    column 'Inquiry Status', :status do |inq|
      inq.status
    end
    column 'Service Name', :service do |inq|
      inq.service.name
    end
    column 'SubCategory Name', :sub_category do |inq|
      inq.sub_category.name
    end
    actions
  end

  show do
    attributes_table do
      row 'User Id',:user_id do |inquiry|
        inquiry.user.id
      end
      row :fist_name do |inquiry|
        inquiry.user.first_name
      end
      row :user_type do |inquiry|
        inquiry.user.type
      end
      row 'Inquiry Status',:status
      row :user_email do |inquiry|
        inquiry.user.email
      end
      row :service do |inquiry|
        inquiry.service.name
      end
      row :sub_category do |inquiry|
        inquiry.sub_category.name
      end
    end
  end

  form do |f|
    f.inputs 'Pending Review' do
      
      if f.object.user.present?
        associated_user = f.object.user
        f.input :first_name, input_html: { value: associated_user.first_name, disabled:true }
        f.input :last_name, input_html: { value: associated_user.last_name, disabled:true }
      end

      if f.object.service.present?
        associated_service = f.object.service
        f.input :service_name, input_html: { value: associated_service.name, disabled:true }
      end

      if f.object.sub_category.present?
        associated_sub_category= f.object.sub_category
        f.input :sub_categoy_name, input_html: { value: associated_sub_category.name, disabled:true }
      end

      f.input :status, label: "Inquiry Status"
      f.input :status_description, as: :string, input_html: { class: 'status-description' }
      f.input :lf_admin_email, label: "LF admin email", as: :select,  collection: AdminUser.all.map(&:email)
      
      f.actions
    end

  end
end