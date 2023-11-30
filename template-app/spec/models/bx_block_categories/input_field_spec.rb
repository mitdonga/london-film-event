require 'rails_helper'

RSpec.describe BxBlockCategories::InputField, type: :model do
    describe 'check validate_edge_case validation' do
        before(:each) do
            @service = FactoryBot.create(:service)
            @service_2 = FactoryBot.create(:service)
            @input_field = BxBlockCategories::InputField.new(
                name: Faker::Lorem.sentence(word_count: 2),
                inputable: @service,
                field_type: "multiple_options"
            )
        end
        
        it "should raise error values or multiplier must be present" do
            @input_field.options = "10,22,33,44"
            @input_field.save
            expect(@input_field.errors.messages.to_s).to include("Values or multiplier must be present for multiple options field")
            expect(@input_field.errors.messages.to_s).to include("Multiplier or Values must be present for multiple options field")
        end
        it "should raise error values and multiplier can't be present at a time" do
            @input_field.options = "11,12,13,24"
            @input_field.values = "101, 210, 302, 405"
            @input_field.multiplier = "1, 1.25, 1.51, 1.99"
            @input_field.save
            expect(@input_field.errors.messages.to_s).to include("Values and multiplier can't be present at a time for multiple options field")
            expect(@input_field.errors.messages.to_s).to include("Multiplier and values can't be present at a time for multiple options field")
        end
        it "should raise values and options mismatch count error" do
            @input_field.options = "14, 23, 36, 49"
            @input_field.values = "102, 220, 380"
            @input_field.save
            expect(@input_field.errors.messages.to_s).to include("Values count must be equal to options count, you entered 4 options but values count is 3")
        end
        it "should raise multiplier and options mismatch count error" do
            @input_field.options = "14, 23, 36, 49"
            @input_field.multiplier = "1, 2, 2.3"
            @input_field.save
            expect(@input_field.errors.messages.to_s).to include("Multiplier count must be equal to options count, you entered 4 options but multiplier count is 3")
        end
        it "should raise non numeric values error" do
            @input_field.options = "10, 21, 32, 44"
            @input_field.values = "103, 202, 307, NA"
            @input_field.save
            expect(@input_field.errors.messages.to_s).to include("Invalid values, please enter comma separated numeric value")
        end
        it "should raise non numeric multiplier error" do
            @input_field.options = "10, 21, 32, 44"
            @input_field.multiplier = "1, 1.4, 1.8, NA"
            @input_field.save
            expect(@input_field.errors.messages.to_s).to include("Invalid multiplier, please enter comma separated numeric multiplier")
        end
        it "should raise > 1 options error" do
            @input_field.options = "100"
            @input_field.values = "130, 240, 370, 420"
            @input_field.save
            expect(@input_field.errors.messages.to_s).to include("Options must be greater than 1")
        end
        it "should save the record" do
            @input_field.options = "102, 112, 231, 345"
            @input_field.values = "1300, 2400, 3700, 4200"
            expect(@input_field.save).to eq(true)
        end
        it "should save the record" do
            @input_field.options = "102, 112, 231, 345"
            @input_field.multiplier = "1.2, 2.1, 3.2, 4.0"
            expect(@input_field.save).to eq(true)
        end
    end
end