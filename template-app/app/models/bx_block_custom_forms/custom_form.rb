module BxBlockCustomForms
  class CustomForm < ApplicationRecord
   self.table_name = :bx_block_custom_forms_custom_forms

   belongs_to :account, class_name: "AccountBlock::Account"
   has_one_attached :file

   enum gender: ["Male", "Female" ]
   enum i_am: ["Tenant", "Owner", "Supervisor"]

   validates_presence_of :first_name, :last_name, :email, :organization, :team_name, :gender, :i_am, :address, :country, :state, :city, :phone_number, :stars_rating
  end
end
