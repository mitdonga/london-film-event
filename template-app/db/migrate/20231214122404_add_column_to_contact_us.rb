class AddColumnToContactUs < ActiveRecord::Migration[6.0]
  def change
    remove_column :contacts, :name, :string
    remove_column :contacts, :phone_number, :string
    remove_column :contacts, :description, :text
    add_column :contacts, :first_name, :string
    add_column :contacts, :last_name, :string
    add_column :contacts, :subject, :string
    add_column :contacts, :details, :text
    add_column :contacts, :phone_number, :bigint
  end
end
