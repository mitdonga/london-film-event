class CreateInputFields < ActiveRecord::Migration[6.0]
  def change
    create_table :input_fields do |t|
      t.string :name
      t.integer :field_type
      t.string :options
      t.string :values
      t.string :multiplier
      t.integer :default_value
      t.string :note
      t.integer :inputable_id
      t.string :inputable_type

      t.timestamps
    end

    add_index :input_fields, [:inputable_id, :inputable_type]
  end
end
