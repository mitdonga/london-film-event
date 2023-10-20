class SetDefaultRoleIdInAccounts < ActiveRecord::Migration[6.0]
  def up
    change_column_default :accounts, :role_id, 1
  end

  def down
    change_column_default :accounts, :role_id, nil
  end
end
