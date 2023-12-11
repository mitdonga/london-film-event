class AddIsValidToAdditionalServices < ActiveRecord::Migration[6.0]
  def change
    add_column :additional_services, :is_valid, :boolean, default: true
  end
end
