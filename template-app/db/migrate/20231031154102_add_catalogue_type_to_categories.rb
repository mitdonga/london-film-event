class AddCatalogueTypeToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :catalogue_type, :integer, default: 0
  end
end
