class AddPackageSubTotalToInquiries < ActiveRecord::Migration[6.0]
  def change
    add_column :inquiries, :package_sub_total, :float
    add_column :inquiries, :addon_sub_total, :float, default: 0.0
    add_column :inquiries, :extra_cost, :float, default: 0.0
  end
end
