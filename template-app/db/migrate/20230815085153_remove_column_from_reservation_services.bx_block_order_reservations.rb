# This migration comes from bx_block_order_reservations (originally 20230403053100)
class RemoveColumnFromReservationServices < ActiveRecord::Migration[6.0]
  def up
    remove_column :reservation_services, :product_name
    add_column :reservation_services, :city, :string
    add_column :reservation_services, :full_address, :string
    add_column :reservation_services, :reservation_date, :datetime
    add_column :reservation_services, :state, :string
    add_column :reservation_services, :zip_code, :integer
    add_column :reservation_services, :service_name, :string
    add_column :reservation_services, :booking_status, :integer
    add_column :reservation_services, :slot_start_time, :string
    add_column :reservation_services, :slot_end_time, :string
  end

  def down
    add_column :reservation_services, :product_name, :string
    remove_column :reservation_services, :city, :string
    remove_column :reservation_services, :full_address, :string
    remove_column :reservation_services, :reservation_date, :datetime
    remove_column :reservation_services, :state, :string
    remove_column :reservation_services, :zip_code, :integer
    remove_column :reservation_services, :service_name, :string
    remove_column :reservation_services, :booking_status, :integer
    remove_column :reservation_services, :slot_start_time, :string
    remove_column :reservation_services, :slot_end_time, :string
  end
end
