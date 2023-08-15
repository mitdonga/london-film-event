# This migration comes from bx_block_custom_user_subs (originally 20201126114842)
class CreateUserSubscription < ActiveRecord::Migration[6.0]
  def change
    create_table :user_subscriptions do |t|
      t.integer :account_id
      t.integer :subscription_id
    end
  end
end
