module AccountBlock
    class ClientUser < Account
      include Wisper::Publisher

      before_validation :set_password, on: :create
      before_save :check_comapny_admin

      belongs_to :client_admin, class_name: "AccountBlock::ClientAdmin"

      validates :client_admin_id, presence: true

      private

      def check_comapny_admin
        unless client_admin.company == company
          errors.add(:client_admin_id, "Client admin belongs to #{client_admin.company.name} but you selected #{company.name} company")
        end
      end

    end
  end