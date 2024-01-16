module BxBlockInvoice
    class Inquiry < ApplicationRecord
        self.table_name = :inquiries

        before_validation :check_service_and_sub_category, on: :create
        after_create :create_additional_service
        after_update :send_email_from_lf

        belongs_to :user, class_name: "AccountBlock::Account"
        belongs_to :service, class_name: "BxBlockCategories::Service"
        belongs_to :sub_category, class_name: "BxBlockCategories::SubCategory"
        
        has_many :additional_services, class_name: "BxBlockCategories::AdditionalService", dependent: :destroy
        has_many :input_values, through: :additional_services, class_name: "BxBlockCategories::InputValue"
        
        has_one_attached :attachment

        enum status: %i[draft pending approved hold rejected]

        has_one_attached :attachment

        def send_email_from_lf
            user = self.user
            if user&.type == "ClientUser"
                client_admin_mail = user.client_admin.email
                BxBlockContactUs::ContactMailer.email_from_lf(client_admin_mail, self.lf_admin_email).deliver_now
            else
                BxBlockContactUs::ContactMailer.email_from_lf(user.email, self.lf_admin_email).deliver_now
            end
        end

        def base_service
            additional_services.find_by(service_id: service.id)
        end

        def extra_services
            additional_services.where.not(service_id: service.id)
        end

        def all_extra_services  # Including discarded is_valid = false
            additional_services.unscoped.where.not(service_id: service.id)
        end

        def user_company
            user.company
        end

        def calculate_addon_cost
            addon_cost = self.input_values.pluck(:cost).map(&:to_f).inject(0.0, :+)
            self.update(addon_sub_total: addon_cost)
        end

        private 

        def check_service_and_sub_category
            unless self.sub_category.parent == self.service
                self.errors.add(:sub_category_id, "Selected sub category doesn't belongs to selected service")
            end
        end

        def create_additional_service
            record = additional_services.new(service_id: service.id)
            record.save!
            sub_category_cost = CompanySubCategory.find_by(company: user_company, sub_category: sub_category)&.price
            self.update(package_sub_total: sub_category_cost)
        end
    end
end
