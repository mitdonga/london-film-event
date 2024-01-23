ActiveAdmin.register BxBlockInvoice::Inquiry, as: 'Pending Reviews' do

  permit_params :id, :first_name, :status, :status_description, :last_name, :user_type, :email, :service_id, :sub_category, :inquiry
  actions :all, except: [:new]
  STATUS = "Inquiry Status"
  scope("Pending Reviews", default: true) { |scope| scope.where.not(status: 'draft') }

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
      row :last_name do |inquiry|
        inquiry.user.last_name
      end
      row :user_type do |inquiry|
        inquiry.user.type
      end
      row :status
      row(:user_email) {|inquiry| inquiry.user.email }
      row(:service) {|inquiry| inquiry.service&.name }
      row(:sub_category) {|inquiry| inquiry.sub_category&.name }
      row :approved_by_lf_admin
      row(:approved_by_client_admin) {|inquiry| inquiry.approved_by_client_admin&.full_name }
    end

    panel "Input Fields" do
      table_for resource.service.input_fields do
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

    panel "Input Values" do
      table_for resource.input_values do
        column :name do |nm|
          nm.user_input
        end
        column :field_type do |ft|
          ft.user_input
        end        
        column :section do |se|
          se.user_input
        end        
        column :options do |op|
          op.user_input
        end
        column :values do |va|
          va.user_input
        end
        column :multiplier do |mu|
          mu.user_input
        end
        column :default_value do |dv|
          dv.user_input
        end
        column :note do |no|
          no.user_input
        end
      end
    end
  end

  form do |f|
    f.inputs 'Pending Review' do
      f.input :full_name, input_html: { value: f.object.user.full_name, disabled:true }
      f.input :service_name, input_html: { value: f.object.service.name, disabled:true }
      f.input :sub_categoy_name, input_html: { value: f.object.sub_category.name, disabled:true }
      f.input :status, label: STATUS, input_html: { id: 'inquiry_status' }
      f.input :status_description, as: :string, input_html: { class: 'status-description', id: 'inquiry_status_description' }
    end
    f.actions
  end

  controller do
    def update
      status = params["bx_block_invoice_inquiry"]["status"] rescue ""
      find_resource.update(approved_by_lf_admin: current_admin_user, lf_admin_approval_required: true) if find_resource.status != status && status == "approved"
      super
    end
  end
end