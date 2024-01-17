class AddColumnToInquiries < ActiveRecord::Migration[6.0]
  def change
    add_column :inquiries, :status_description, :text
    add_column :inquiries, :lf_admin_email, :string
  end
end
