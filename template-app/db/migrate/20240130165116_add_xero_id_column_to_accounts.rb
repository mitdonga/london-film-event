class AddXeroIdColumnToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :xero_id, :string
  end
end
