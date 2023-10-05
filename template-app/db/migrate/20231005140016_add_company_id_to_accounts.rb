class AddCompanyIdToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :company_id, :bigint
  end
end
