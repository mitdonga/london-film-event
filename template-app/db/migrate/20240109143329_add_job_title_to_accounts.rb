class AddJobTitleToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :job_title, :string
    add_column :accounts, :can_create_accounts, :boolean, default: false

    AccountBlock::ClientAdmin.update_all(can_create_accounts: true)
  end
end
