# spec/serializers/bx_block_account_groups/client_user_serializer_spec.rb
require 'rails_helper'
# require 'json_matcher/rspec'

RSpec.describe BxBlockAccountGroups::ClientUserSerializer, type: :serializer do
  let(:client_admin) { create(:admin_account) }
  let(:client_user) { create(:user_account, client_admin_id: client_admin.id) }
  subject(:serialization) { described_class.new(client_user).serializable_hash.to_json }

  it 'serializes the client_user with inquiries' do
    expected_json = {
        data: {
          id: client_user.id.to_s,
          type: 'client_user',
          attributes: {
            inquiries: []
            # Add more attributes as needed
          }
        }
    }.to_json
  
      expect(serialization).to eq(expected_json)
      end
end
