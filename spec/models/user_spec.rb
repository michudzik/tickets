require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'attributes' do
    it 'should have proper attributes' do
      expect(subject.attributes).to include('first_name', 'last_name')
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end

  describe 'relations' do
    it { should belong_to(:role) }
    it { should have_many(:comments) }
  end

  describe 'callbacks' do
    let(:user) { create(:user) }
    it 'should set role to none if not given' do
      expect(user.role.name).to eq('none')
    end
  end

  describe 'methods' do
    let!(:admin_role)        { create(:admin) }
    let!(:none_role)         { create(:none) }
    let!(:it_support_role)   { create(:it_support) }
    let!(:om_support_role)   { create(:om_support) }
    let(:user) { create(:user) }

    describe '#admin?' do
      it 'should return true' do
        user.role = admin_role
        expect(user.admin?).to eq(true)
      end

      it 'should return false' do
        expect(user.admin?).to eq(false)
      end
    end

    describe '#it_support?' do
      it 'should return true' do
        user.role = it_support_role
        expect(user.it_support?).to eq(true)
      end

      it 'should return false' do
        expect(user.it_support?).to eq(false)
      end
    end

    describe '#om_support?' do
      it 'should return true' do
        user.role = om_support_role
        expect(user.om_support?).to eq(true)
      end

      it 'should return false' do
        expect(user.om_support?).to eq(false)
      end
    end

    describe '#full_name' do
      it 'should return full name' do
        expect(user.full_name).to eq("#{user.first_name} #{user.last_name}")
      end
    end
  end

end
