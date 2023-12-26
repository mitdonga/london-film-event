class CreateCompanyInputFields < ActiveRecord::Migration[6.0]
  def change
    create_table :company_input_fields do |t|
      t.bigint :company_id
      t.bigint :input_field_id
      t.string :values
      t.string :multiplier
      t.integer :default_value
      t.string :note
      
      t.timestamps
    end
  end
end
