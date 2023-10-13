class AddAccountTypeToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :account_type, :integer
  end
end
