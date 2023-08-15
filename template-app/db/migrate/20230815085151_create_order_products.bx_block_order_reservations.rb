# This migration comes from bx_block_order_reservations (originally 20230315123753)
class CreateOrderProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :order_products do |t|
      t.string :product_name
      t.float :price

      t.timestamps
    end
  end
end
