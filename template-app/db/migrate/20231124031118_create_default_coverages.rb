class CreateDefaultCoverages < ActiveRecord::Migration[6.0]
  def change
    create_table :default_coverages do |t|
      t.string :title
      t.integer :rank
      t.integer :sub_category_id
      t.integer :category

      t.timestamps
    end
  end
end
