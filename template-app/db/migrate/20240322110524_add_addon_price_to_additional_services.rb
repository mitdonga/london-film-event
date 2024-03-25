class AddAddonPriceToAdditionalServices < ActiveRecord::Migration[6.0]
  def change
    add_column :additional_services, :addon_price, :float
    add_column :additional_services, :sub_category_price, :float
    add_column :additional_services, :sub_category_id, :bigint
  end
end
