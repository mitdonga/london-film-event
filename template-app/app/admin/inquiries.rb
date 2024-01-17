ActiveAdmin.register BxBlockInvoice::Inquiry, as: 'Pending Reviews' do

  permit_params :id, :first_name, :status, :status_description, :last_name, :user_type, :email, :service, :sub_category, :lf_admin_email
  actions :all, except: [:new]
  STATUS = "Inquiry Status"

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
    column STATUS, :status do |inq|
      inq.status
    end
    column 'Service Name', :service do |inq|
      inq.service&.name
    end
    column 'SubCategory Name', :sub_category do |inq|
      inq.sub_category&.name
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
      row :status
      row :user_email do |inquiry|
        inquiry.user.email
      end
      row :service do |inquiry|
        inquiry.service&.name
      end
      row :sub_category do |inquiry|
        inquiry.sub_category&.name
      end
      row :approved_by_lf_admin
      row :approved_by_client_admin do |inquiry|
        inquiry.approved_by_client_admin&.full_name
      end

    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
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

      f.input :status, label: STATUS
      f.input :status_description, as: :string, input_html: { class: 'status-description' }
      f.input :lf_admin_email, label: "LF admin email", as: :select,  collection: AdminUser.all.map(&:email)
      
      f.actions
    end

  end

  controller do
    def update
      status = params["bx_block_invoice_inquiry"]["status"] rescue ""
      # params["bx_block_invoice_inquiry"]["approved_by_lf_admin_id"] = current_admin_user.id if find_resource.status != status && status == "approved"
      find_resource.update(approved_by_lf_admin: current_admin_user)
      super
    end
  end
end