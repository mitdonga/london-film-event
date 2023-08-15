module BxBlockCustomForms
  module PatchAccountCustomFormsAssociations
    extend ActiveSupport::Concern

    included do
      has_one :custom_form, class_name: 'BxBlockCustomForms::CustomForm', dependent: :destroy
    end
  end
end
