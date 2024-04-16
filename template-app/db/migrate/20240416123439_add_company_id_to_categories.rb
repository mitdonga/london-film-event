class AddCompanyIdToCategories < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :company_id, :bigint
  end
end
