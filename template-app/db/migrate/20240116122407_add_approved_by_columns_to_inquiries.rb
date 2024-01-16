class AddApprovedByColumnsToInquiries < ActiveRecord::Migration[6.0]
  def change
    add_column :inquiries, :approved_by_client_admin_id, :integer
    add_column :inquiries, :approved_by_lf_admin_id, :integer
    add_column :inquiries, :lf_admin_approval_required, :boolean, default: false
  end
end
