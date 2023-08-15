# This migration comes from bx_block_order_reservations (originally 20230403052830)
class RenameOrderProductsTableName < ActiveRecord::Migration[6.0]
  def up
    rename_table :order_products, :reservation_services
  end

  def down
    rename_table :reservation_services, :order_products
  end
end
