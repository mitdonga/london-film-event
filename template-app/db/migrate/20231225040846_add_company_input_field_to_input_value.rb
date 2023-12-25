class AddCompanyInputFieldToInputValue < ActiveRecord::Migration[6.0]
  def change
    add_column :input_values, :company_input_field_id, :bigint
    
    BxBlockInvoice::Inquiry.all.destroy_all
    BxBlockCategories::InputValue.all.destroy_all
  end
end
