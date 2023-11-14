ActiveAdmin.register BxBlockTermsAndConditions::UserTermAndCondition, as: "Users Terms And Condition" do
  menu false
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :account_id, :terms_and_condition_id, :is_accepted
  #
  # or
  #
  # permit_params do
  #   permitted = [:account_id, :terms_and_condition_id, :is_accepted]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
