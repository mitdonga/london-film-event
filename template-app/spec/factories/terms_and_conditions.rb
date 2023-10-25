FactoryBot.define do
    factory :term, class: "BxBlockTermsAndConditions::TermsAndCondition" do
        description { "Some text" }
        for_whom {"client_users"}
    end
end