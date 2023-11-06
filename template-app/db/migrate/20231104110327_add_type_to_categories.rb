class AddTypeToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :type, :string
  end
end
