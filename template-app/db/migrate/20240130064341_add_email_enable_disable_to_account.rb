class AddEmailEnableDisableToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :email_enable, :boolean, default: true
  end
end
