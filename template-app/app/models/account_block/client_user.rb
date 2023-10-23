module AccountBlock
    class ClientUser < Account
      include Wisper::Publisher

      before_validation :set_password, on: :create

      belongs_to :client_admin, class_name: "AccountBlock::ClientAdmin"

    end
  end