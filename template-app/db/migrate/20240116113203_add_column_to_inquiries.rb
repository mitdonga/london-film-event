class AddColumnToInquiries < ActiveRecord::Migration[6.0]
  def change
    add_column :inquiries, :status_description, :text
  end
end
