# This migration comes from bx_block_order_reservations (originally 20230403062510)
class RemoveColumnsFromAccountOrder < ActiveRecord::Migration[6.0]
  def up
    remove_column :account_orders, :or_product_id, :integer
    add_column :account_orders, :reservation_service_id, :integer
  end

  def down
    add_column :account_orders, :or_product_id, :integer
    remove_column :account_orders, :reservation_service_id, :integer
  end
end
