class AddClientAdminToClientUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :client_admin_id, :bigint
  end
end
