class AddInputFieldDataToInputValues < ActiveRecord::Migration[6.0]
  def change
    add_column :input_values, :input_field_data, :json, default: {}
  end
end
