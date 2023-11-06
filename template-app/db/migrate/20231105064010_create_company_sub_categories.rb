class CreateCompanySubCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :company_sub_categories do |t|
      t.bigint :company_id, null: false
      t.bigint :sub_category_id, null: false
      t.integer :price

      t.timestamps
    end
  end
end
