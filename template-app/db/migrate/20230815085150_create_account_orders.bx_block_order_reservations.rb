# This migration comes from bx_block_order_reservations (originally 20230315080903)
class CreateAccountOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :account_orders do |t|
      t.references :account
      t.integer :quantity
      t.float :total_price
      t.datetime :placed_date_time
      t.integer :order_status, default: 0
      t.integer :or_product_id

      t.timestamps
    end
  end
end
