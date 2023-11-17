class ChangeHasAccessColumn < ActiveRecord::Migration[6.0]
  def change
    change_column_default :company_categories, :has_access, from: false, to: true
  end
end
