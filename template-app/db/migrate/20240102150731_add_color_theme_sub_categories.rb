class AddColorThemeSubCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_categories, :color_theme, :string
  end
end
