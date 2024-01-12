class AddStatusFieldToAccount < ActiveRecord::Migration[6.0]
  def change
    add_column :accounts, :pending_review_status, :integer
  end
end
