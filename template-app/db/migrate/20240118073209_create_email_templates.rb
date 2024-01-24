class CreateEmailTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :email_templates do |t|
      t.string :name
      t.text :body
      t.string :dynamic_words
      
      t.timestamps
    end

    BxBlockEmailNotifications::EmailTemplate.create([
      {name: "User Account Creation", dynamic_words: "user_name", body: "Email body"},
      {name: "Password Reset", dynamic_words: "user_name", body: "Email body"},
      {name: "Client User Request For Quote (All Packages)", dynamic_words: "user_name", body: "Email body"},
      {name: "Client User/Admin Request For Quote (Bespoke Packages)", dynamic_words: "user_name", body: "Email body"},
      {name: "New Bespoke Package Added", dynamic_words: "user_name", body: "Email body"},
      {name: "Client Admin Approve The Package", dynamic_words: "user_name", body: "Email body"},
    ])
  end
end
