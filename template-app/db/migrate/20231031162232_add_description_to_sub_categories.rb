class AddDescriptionToSubCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :sub_categories, :start_from, :integer
		add_column :sub_categories, :description, :string
		add_column :sub_categories, :duration, :integer
  end
end
