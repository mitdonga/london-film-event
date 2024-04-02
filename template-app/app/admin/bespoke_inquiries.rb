ActiveAdmin.register BxBlockInvoice::Inquiry, as: 'Bespoke Inquiry' do

    permit_params :id, :first_name, :status, :extra_cost, :status_description, :last_name, :user_type, :email, :service_id, :sub_category, :inquiry, input_values_attributes: [:id, :cost]
    actions :all, except: [:new]
    scope("Inquiry", default: true) { |inquiry| inquiry.includes(:user, input_values: [additional_service: :service]).where("status not in (?) and is_bespoke = true", [0]).order(created_at: :desc, status: :asc) }
  
    index do
      selectable_column
      id_column
      column :user_id
      column :first_name do |inq|
        inq.user&.first_name
      end
      column 'Last Name' do |inq|
        inq.user&.last_name
      end
      column 'Email' do |inq|
        inq.user&.email
      end
      column :status
      column 'Service Name' do |iqy|
        iqy.status == "partial_approved" ? "Pending" : iqy.status&.humanize
      end
      column 'Sub Category Name' do |inq|
        inq.sub_category&.name
      end
      column :created_at
      actions
    end
  
    show do
      price_data = resource.get_prices
      attributes_table do
        row :user_id
        row :fist_name do |inquiry|
          inquiry.user&.first_name
        end
        row :last_name do |inquiry|
          inquiry.user&.last_name
        end
        row :user_type do |inquiry|
          inquiry.user&.type
        end
        row(:status) {|inquiry| inquiry.status == "partial_approved" ? "Pending" : inquiry.status&.humanize}
        row(:user_email) {|inquiry| inquiry.user&.email }
        row(:service) {|inquiry| inquiry.service&.name }
        row(:sub_category) {|inquiry| inquiry.sub_category&.name }
        row :approved_by_lf_admin
        row(:approved_by_client_admin) {|inquiry| inquiry.approved_by_client_admin&.full_name }
        row(:provisional_cost) {price_data[:provisional_cost] }
        row(:provisional_addon_cost) {price_data[:provisional_addon_cost] }
        row(:additional_services_cost) {price_data[:additional_services_cost] }
        row(:additional_addons_cost) {price_data[:additional_addons_cost] }
        row(:extra_cost) {price_data[:extra_cost] }
        row(:sub_total) {price_data[:sub_total] }
        row(:total_addon_cost) {price_data[:total_addon_cost] }
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
          column :id 
          column :name do |iv|
            iv.current_input_field&.name
          end
          column :user_input   
          column :cost    
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
        f.input :status, label: STATUS, collection: [["Pending", "pending"], ["Approved", "partial_approved"], ["Hold", "hold"], ["Rejected", "rejected"]]
        f.input :status_description, as: :string, input_html: { class: 'status-description', id: 'inquiry_status_description' }
        f.input :extra_cost
        f.has_many :input_values, 
            heading: 'Manage Cost',                    
            allow_destroy: false,
            new_record: false,
            class: 'input-values-container' do |s|
              s.input :id, as: :hidden
              s.input :name, input_html: { disabled: true }
              s.input :service_name, input_html: { value: s.object.additional_service.service.name, disabled:true }
              s.input :user_input, input_html: { disabled: true }
              s.input :cost
          end
      end
      f.actions
    end
  
    controller do
      def update
        status = params["bx_block_invoice_inquiry"]["status"] rescue ""
        find_resource.update(approved_by_lf_admin: current_admin_user) if find_resource.status != status && status == "partial_approved"
        find_resource.update(rejected_by_lf: current_admin_user) if find_resource.status != status && status == "rejected"
        find_resource.update(hold_by: current_admin_user) if find_resource.status != status && status == "hold"
        super
        find_resource.calculate_addon_cost
      end
    end
  end