module AccountBlock
    class ClientAdmin < Account
      include Wisper::Publisher

      after_create :allow_account_creation

      has_many :client_users, class_name: "AccountBlock::ClientUser", dependent: :destroy
    
      def allow_account_creation
        self.update(can_create_accounts: true)
      end
    end
end