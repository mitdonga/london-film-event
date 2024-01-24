class AddTokenExpireFieldToUserActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :token_expires_at, :datetime
    add_column :accounts, :session_duration, :string
  end
end
