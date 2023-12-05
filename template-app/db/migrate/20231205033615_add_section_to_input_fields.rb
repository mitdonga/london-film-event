class AddSectionToInputFields < ActiveRecord::Migration[6.0]
  def change
    add_column :input_fields, :section, :integer
  end
end
