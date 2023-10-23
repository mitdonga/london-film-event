module AccountBlock
    class ClientAdmin < Account
      include Wisper::Publisher

      has_many :client_users, class_name: "AccountBlock::ClientUser", dependent: :destroy
    end
end