class CreateInputValues < ActiveRecord::Migration[6.0]
  def change
    create_table :input_values do |t|
      t.integer :input_field_id
      t.bigint :additional_service_id
      t.string :user_input
      t.float :cost

      t.timestamps
    end
  end
end
