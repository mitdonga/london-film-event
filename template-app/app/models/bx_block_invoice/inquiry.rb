module BxBlockInvoice
    class Inquiry < ApplicationRecord
        self.table_name = :inquiries

        before_validation :check_service_and_sub_category, on: :create
        after_create :create_additional_service

        belongs_to :user, class_name: "AccountBlock::Account"
        belongs_to :service, class_name: "BxBlockCategories::Service"
        belongs_to :sub_category, class_name: "BxBlockCategories::SubCategory"
        
        has_many :additional_services, class_name: "BxBlockCategories::AdditionalService", dependent: :destroy
        has_many :input_values, through: :additional_services, class_name: "BxBlockCategories::InputValue"
        
        has_one_attached :attachment

        enum status: %i[draft pending approved]

        private 

        def check_service_and_sub_category
            unless self.sub_category.parent == self.service
                self.errors.add(:sub_category_id, "Selected sub category doesn't belongs to selected service")
            end
        end

        def create_additional_service
            record = additional_services.new(service_id: service.id)
            record.save!
        end
    end
end
