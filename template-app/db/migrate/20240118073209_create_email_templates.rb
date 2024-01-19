class CreateEmailTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :email_templates do |t|
      t.string :name
      t.text :body
      t.string :required_words, array: true, default: []
      
      t.timestamps
    end
  end
end
