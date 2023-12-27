class AddNoteToInputValues < ActiveRecord::Migration[6.0]
  def change
    add_column :input_values, :note, :string
  end
end
