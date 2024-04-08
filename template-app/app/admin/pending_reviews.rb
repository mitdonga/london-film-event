ActiveAdmin.register BxBlockInvoice::Inquiry, as: 'Pending Reviews' do

    permit_params :id, :first_name, :status, :status_description, :last_name, :user_type, :email, :service_id, :sub_category, :inquiry
    actions :all, except: [:new]
    STATUS = "Enquiry Status"
    scope("Pending Reviews", default: true) { |scope| scope.where("status in (?) and lf_admin_approval_required = true and is_bespoke = false", [2, 3]).order(:status) }
  
    index do
      selectable_column
      id_column
      column 'User Id', :id do |inq|
        inq.user&.id
      end
      column 'First Name', :first_name do |inq|
        inq.user&.first_name
      end
      column 'Last Name', :last_name do |inq|
        inq.user&.last_name
      end
      column 'Email', :email do |inq|
        inq.user&.email
      end
      column "Current Status" do |iq|
        iq.status == "partial_approved" ? "Pending" : iq.status&.humanize
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
      price_data = resource.get_prices
      attributes_table do
        row 'User Id',:user_id do |inquiry|
          inquiry.user&.id
        end
        row :fist_name do |inquiry|
          inquiry.user&.first_name
        end
        row :last_name do |inquiry|
          inquiry.user&.last_name
        end
        row :user_type do |inquiry|
          inquiry.user&.type
        end
        row "Current Status" do |inqy|
          inqy.status == "partial_approved" ? "Pending" : inqy.status&.humanize
        end
        row(:user_email) {resource.user&.email }
        row(:service) {resource.service&.name }
        row(:sub_category) {resource.sub_category&.name }
        row(:approved_by_client_admin) {resource.approved_by_client_admin&.full_name }
        row :status_description
        row(:provisional_cost) {price_data[:provisional_cost] }
        row(:provisional_addon_cost) {price_data[:provisional_addon_cost] }
        row(:additional_services_cost) {price_data[:additional_services_cost] }
        row(:additional_addons_cost) {price_data[:additional_addons_cost] }
        row(:extra_cost) {price_data[:extra_cost] }
        row(:sub_total) {price_data[:sub_total] }
        row(:total_addon_cost) {price_data[:total_addon_cost] }
        row :updated_at
        row :created_at
      end
  panel "Input Values" do
    table_for resource.input_values do
      column :id do |iv|
        iv.id
      end
      column :name do |iv|
        iv.current_input_field.name
      end
      column :user_input do |iv|
        iv.user_input
      end    
      # column :cost do |iv|
      #   iv.cost
      # end     
      column :options do |iv|
        iv.current_input_field.options
      end
      column :values do |iv|
        iv.current_input_field.values
      end
      column :multiplier do |iv|
        iv.current_input_field.multiplier
      end
      column :default_value do |iv|
        iv.current_input_field.default_value
      end
      column :field_type do |iv|
        iv.current_input_field.field_type
      end        
      column :section do |iv|
        iv.current_input_field.section
      end
    end
  end
  
    end
  
    form do |f|
      f.inputs 'Pending Review' do
        f.input :full_name, input_html: { value: f.object.user.full_name, disabled:true }
        f.input :service_name, input_html: { value: f.object.service.name, disabled:true }
        f.input :sub_categoy_name, input_html: { value: f.object.sub_category.name, disabled:true }
        f.input :status, label: STATUS, collection: [["Pending", "pending"], ["Approved", "partial_approved"], ["Hold", "hold"], ["Rejected", "rejected"]]
        f.input :status_description
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
      end
    end
  end