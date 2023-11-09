class CreateCompanyCategories < ActiveRecord::Migration[6.0]
  def change
    create_table :company_categories do |t|
      t.bigint :company_id, null: false
      t.bigint :category_id, null: false
      t.boolean :has_access, default: false

      t.timestamps
    end
  end
end
