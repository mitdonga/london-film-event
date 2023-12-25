
  
FactoryBot.define do
  
  factory :company_input_field, class: "BxBlockCategories::CompanyInputField" do
    input_field_id { input_field.id }
    company_id { FactoryBot.create(:company).id }
    values { input_field.values }
    multiplier { input_field.multiplier }
    default_value { input_field.default_value }

    before(:create) do
      input_field = FactoryBot.create(:input_field)
    end
  end

  factory :company_input_field_multi_option_value, class: "BxBlockCategories::CompanyInputField" do
    input_field_id { input_field_multi_option_value.id }
    company_id { FactoryBot.create(:company).id }
    values { input_field_multi_option_value.values }
    multiplier { input_field_multi_option_value.multiplier }
    default_value { input_field_multi_option_value.default_value }

    before(:create) do
      input_field_multi_option_value = FactoryBot.create(:input_field_multi_option_value)
    end
  end

  factory :company_input_field_multi_option_multiplier, class: "BxBlockCategories::CompanyInputField" do
    input_field_id { input_field_multi_option_multiplier.id }
    company_id { FactoryBot.create(:company).id }
    values { input_field_multi_option_multiplier.values }
    multiplier { input_field_multi_option_multiplier.multiplier }
    default_value { input_field_multi_option_multiplier.default_value }

    before(:create) do
      input_field_multi_option_multiplier = FactoryBot.create(:input_field_multi_option_multiplier)
    end
  end
end
