class AddShouldResetPasswordToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :should_reset_password, :boolean, default: true
  end
end
