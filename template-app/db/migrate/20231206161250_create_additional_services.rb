class CreateAdditionalServices < ActiveRecord::Migration[6.0]
  def change
    create_table :additional_services do |t|
      t.bigint :inquiry_id
      t.integer :service_id

      t.timestamps
    end
  end
end
