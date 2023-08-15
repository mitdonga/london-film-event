# This migration comes from bx_block_custom_forms (originally 20230602115335)
class AddStarsRatingInBxBlockCustomFormsCustomForms < ActiveRecord::Migration[6.0]
  def change
  	add_column :bx_block_custom_forms_custom_forms, :stars_rating, :integer 
  end
end
