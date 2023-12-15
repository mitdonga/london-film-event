require 'rails_helper'

RSpec.describe BxBlockContactUs::Contact, type: :model do
 
  describe 'validations' do
    it 'validates presence of attributes' do
      contact = BxBlockContactUs::Contact.new
      contact.valid?
      expect(contact.errors[:account]).to include("must exist")
      expect(contact.errors[:first_name]).to include("can't be blank")
      expect(contact.errors[:last_name]).to include("can't be blank")
      expect(contact.errors[:email]).to include("can't be blank")
      expect(contact.errors[:phone_number]).to include("must be a valid 10-digit phone number")
    end
  end

  describe 'associations' do
    it { should belong_to(:account).class_name('AccountBlock::Account') }
  end

  describe 'custom validations' do
    describe '#valid_email' do
      context 'when email is valid' do
        it 'does not add errors' do
          contact = build(:contact, email: 'valid@example.com')
          contact.valid?
          expect(contact.errors[:email]).to be_empty
        end
      end

      context 'when email is invalid' do
        it 'adds an error' do
          contact = build(:contact, email: 'invalid_email')
          contact.valid?
          expect(contact.errors[:email]).to include('invalid')
        end
      end
    end
  end
end