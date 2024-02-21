ActiveAdmin.register BxBlockInvoice::Inquiry, as: 'Bespoke Inquiry' do

    permit_params :id, :first_name, :status, :extra_cost, :status_description, :last_name, :user_type, :email, :service_id, :sub_category, :inquiry, input_values_attributes: [:id, :cost]
    actions :all, except: [:new]
    scope("Inquiry", default: true) { |inquiry| inquiry.includes(:input_values).where("status not in (?) and is_bespoke = true", [0]).order(created_at: :desc, status: :asc) }
  
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
      column :status do |inq|
        inq.status
      end
      column 'Service Name', :service do |inq|
        inq.service&.name
      end
      column 'Sub Category Name' do |inq|
        inq.sub_category&.name
      end
      column :created_at
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
        row :package_sub_total
        row :addon_sub_total
        row :extra_cost
        row "Total Cost" do |inq|
          inq.total_price
        end
        row :created_at
        row :updated_at
        row :files do |inq|
          ul do
            inq.files.each do |file|
              li link_to(file.filename, url_for(file))
            end
          end
        end
      end

  
      panel "Input Values" do
        table_for resource.input_values do
          column :id do |iv|
            iv.id
          end
          column :name do |iv|
            iv.current_input_field&.name
          end
          column :user_input do |iv|
            iv.user_input
          end      
          column :cost do |iv|
            iv.cost
          end      
          column :options do |iv|
            iv.current_input_field&.options
          end
          column :values do |iv|
            iv.current_input_field&.values
          end
          column :multiplier do |iv|
            iv.current_input_field&.multiplier
          end
          column :default_value do |iv|
            iv.current_input_field&.default_value
          end
          column :field_type do |iv|
            iv.current_input_field&.field_type
          end        
          column :section do |iv|
            iv.current_input_field&.section
          end
        end
      end
    end
  
    form do |f|
      f.inputs do
        f.input :full_name, input_html: { value: f.object.user.full_name, disabled:true }
        f.input :service_name, input_html: { value: f.object.service.name, disabled:true }
        f.input :sub_categoy_name, input_html: { value: f.object.sub_category.name, disabled:true }
        f.input :status, label: STATUS, collection: [["Pending", "pending"], ["Approved", "approved"], ["Hold", "hold"], ["Reject", "rejected"]]
        f.input :status_description, as: :string, input_html: { class: 'status-description', id: 'inquiry_status_description' }
        f.input :extra_cost
        f.has_many :input_values, 
            heading: 'Manage Cost',                    
            allow_destroy: false,
            new_record: false,
            class: 'input-values-container' do |s|
              # s.input :id
              s.input :name, input_html: { disabled: true }
              s.input :user_input, input_html: { disabled: true }
              s.input :cost
          end
      end
      f.actions
    end
  
    controller do
      def update
        status = params["bx_block_invoice_inquiry"]["status"] rescue ""
        find_resource.update(approved_by_lf_admin: current_admin_user, lf_admin_approval_required: true) if find_resource.status != status && status == "approved"
        super
        find_resource.calculate_addon_cost
      end
    end
  end