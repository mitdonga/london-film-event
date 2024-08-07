module BxBlockInvoice
    class Inquiry < ApplicationRecord
        self.table_name = :inquiries

        before_validation :check_for_bespoke, on: :create
        before_validation :check_service_and_sub_category, on: :create
        
        after_create :create_additional_service
        after_create :set_default_input_values
        after_update :send_email_from_lf
        # before_update :notify_user_after_approval, if: :status_changed?
        before_update :update_status_timestamp, if: :status_changed?

        belongs_to :rejected_by_lf, class_name: "AdminUser", optional: true
        belongs_to :rejected_by_ca, class_name: "AccountBlock::Account", optional: true
        belongs_to :user, class_name: "AccountBlock::Account"
        belongs_to :approved_by_client_admin, class_name: "AccountBlock::Account", optional: true
        belongs_to :approved_by_lf_admin, class_name: "AdminUser", optional: true
        belongs_to :service, class_name: "BxBlockCategories::Service"
        belongs_to :sub_category, class_name: "BxBlockCategories::SubCategory"
        
        has_many :additional_services, class_name: "BxBlockCategories::AdditionalService", dependent: :destroy
        has_many :input_values, through: :additional_services, class_name: "BxBlockCategories::InputValue"
        # has_many :non_required_input_values, -> {joins(:input_field).includes(:input_field).where("input_fields.section != ?", 0)}, through: :additional_services, class_name: "BxBlockCategories::InputValue"

        has_one_attached :attachment
        has_many_attached :files

        enum status: %i[unsaved draft pending partial_approved approved hold rejected]

        accepts_nested_attributes_for :input_values

        # validates :approved_by_lf_admin, presence: true, if: -> { lf_admin_approval_required == true && status == "approved" }
        # validates :approved_by_client_admin, presence: true, if: -> { status == "approved" && approved_by_lf_admin.blank? }
        validates :status_description, presence: true, if: -> { (status == "hold" || status == "rejected") && rejected_by_lf_id.present? }

        def send_email_from_lf
            user = self.user
            @lf_mail = approved_by_lf_admin.email if approved_by_lf_admin.present?
            if user&.type == "ClientUser"
                client_admin_mail = user.client_admin.email
                BxBlockContactUs::ContactMailer.email_from_lf(client_admin_mail, @lf_mail).deliver_now
            else
                BxBlockContactUs::ContactMailer.email_from_lf(user.email, @lf_mail).deliver_now
            end
        end

        def required_input_values
            input_values.joins(:input_field).includes(:input_field).where("input_fields.section = ?", 0) #required_information
        end

        # def non_required_input_values
        #     input_values.joins(:input_field).includes(:input_field).where("input_fields.section != ?", 0) #required_information
        # end

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
            update_additional_service_cost
        end

        def update_additional_service_cost
            additional_services.map(&:set_prices)
        end

        def event_date
            input_values.joins(:input_field).where("input_fields.name ilike ?", "%event date%").first&.user_input rescue ""
        end

        def client_name
            input_values.joins(:input_field).where("input_fields.name ilike ?", "%client name%").first&.user_input rescue ""
        end

        def event_name
            input_values.joins(:input_field).where("input_fields.name ilike ?", "%event name%").first&.user_input rescue ""
        end

        def event_start_time
            input_values.joins(:input_field).where("input_fields.name ilike ?", "%event start time%").first&.user_input rescue ""
        end

        def event_end_time
            input_values.joins(:input_field).where("input_fields.name ilike ?", "%event end time%").first&.user_input rescue ""
        end

        def event_location
            input_values.joins(:input_field).where("input_fields.name ilike ?", "%location%").first&.user_input rescue ""
        end

        def event_budget
            input_values.joins(:input_field).where("input_fields.name ilike ?", "%event budget%").first&.user_input rescue ""
        end

        def event_days
            input_values.joins(:input_field).where("input_fields.name ilike ?", "%event days%").first&.user_input rescue ""
        end

        def days_coverage
            input_values.joins(:input_field).where("input_fields.name ilike ? or input_fields.name ilike ?", "%how many days coverage%", "%how many day coverage%").first.user_input.downcase.gsub(/[^0-9.]/, '').strip.to_f rescue nil
        end

        def is_full_day
            sub_category.name.downcase.include?("full") rescue false
        end

        def is_half_day
            sub_category.name.downcase.include?("half") rescue false
        end

        def is_multi_day
            sub_category.name.downcase.include?("multi") rescue false
        end

        # def is_bespoke
        #     sub_category.name.downcase.include?("bespoke") rescue false
        # end

        def total_price
            package_sub_total.to_f + addon_sub_total.to_f + extra_cost.to_f
        end

        def get_prices
            additional_services = self.extra_services
            additional_addons_cost, additional_services_cost = 0.0, 0.0
            additional_services.each do |as|
                additional_addons_cost = as.addon_price.to_f
                additional_services_cost += as.sub_category_price.to_f
            end
            provisional_addon_cost = self.base_service.input_values.pluck(:cost).map(&:to_f).inject(0.0, :+) rescue 0.0
            data = {}
            data[:provisional_cost] = self.package_sub_total.to_f
            data[:provisional_addon_cost] = provisional_addon_cost
            data[:extra_cost] = self.extra_cost.to_f
            data[:additional_services_cost] = additional_services_cost
            data[:additional_addons_cost] = additional_addons_cost
            data[:sub_total] = data.values.map(&:to_f).sum
            data[:total_addon_cost] = self.addon_sub_total.to_f
            data
        end

        def set_default_input_values
            camp_iv =  input_values.joins(:input_field).where("input_fields.name ilike ?", "%company name%").first
            if camp_iv.present?
                camp_iv.update(user_input: user.company.name)
            end
            clt_iv = input_values.joins(:input_field).where("input_fields.name ilike ?", "%client name%").first
            if clt_iv.present?
                clt_iv.update(user_input: user.full_name)
            end
        end

        private 

        # def notify_user_after_approval
        #     InquiryMailer.inquiry_approved(self.id).deliver_later if self.status == "approved"
        # end

        def check_service_and_sub_category
            unless self.sub_category&.parent == self.service
                self.errors.add(:sub_category_id, "Selected sub category doesn't belongs to selected service")
            end
        end

        def update_status_timestamp
            case self.status
            when "draft"
                self.draft_at = Time.now
            when "pending"
                self.submitted_at = Time.now
            when "partial_approved"
                self.partial_approved_at = Time.now
            when "approved"
                self.approved_at = Time.now
            when "rejected"
                self.rejected_at = Time.now
            when "hold"
                self.hold_at = Time.now
            end
        end

        def check_for_bespoke
            subc = sub_category.name.downcase.include?("bespoke") rescue nil
            if subc.present? || self.service.is_custom_service?
                self.is_bespoke, self.lf_admin_approval_required = true, true
            elsif service.name.downcase.include?("bespoke") && subc.nil?
                subc = service.sub_categories.find_by('name ilike ?', '%bespoke%') rescue nil
                if subc.present?
                    self.is_bespoke, self.lf_admin_approval_required, self.sub_category = true, true, subc
                else
                    self.errors.add(:sub_category_id, "Bespoke package not found")
                end
            end
        rescue Exception => e
            self.errors.add(:base, "Not able to create bespoke inquiry"); puts e
        end

        def create_additional_service
            record = additional_services.new(service_id: service.id)
            record.save!
            sub_category_cost = CompanySubCategory.find_by(company: user_company, sub_category: sub_category)&.price
            self.update(package_sub_total: sub_category_cost)
        end
    end
end
