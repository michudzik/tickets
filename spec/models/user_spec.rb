require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'attributes' do
    let!(:role) { Role.create(name: 'none') }
    it 'should have proper attributes' do
      expect(subject.attributes).to include('first_name', 'last_name')
    end
  end

  describe 'validations' do
    let!(:role) { Role.create(name: 'none') }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
	it { should have_many(:comments) }
  end

  describe 'relations' do
    let!(:role) { Role.create(name: 'none') }
    it { should belong_to(:role) }
  end

  describe 'callbacks' do
    let!(:role) { Role.create(name: 'none') }
    let(:user) { User.create(first_name: 'Example', last_name: 'Example', email: "#{Faker::Name.first_name}@example.com", password: 'secret') }
    it 'should set role to none if not given' do
      expect(user.role.name).to eq('none')
    end
  end

  describe 'methods' do
    describe '#admin?' do
      let!(:role) { Role.create(name: 'admin') }
      let!(:role_1) { Role.create(name: 'none') }
      let(:user) { User.create(first_name: 'Example', last_name: 'Example', email: "#{Faker::Name.first_name}@example.com", password: 'secret') }

      it 'should return true' do
        user.role = role
        expect(user.admin?).to eq(true)
      end

      it 'should return false' do
        expect(user.admin?).to eq(false)
      end
    end

    describe '#it_support?' do
      let!(:role) { Role.create(name: 'it_support') }
      let!(:role_1) { Role.create(name: 'none') }
      let(:user) { User.create(first_name: 'Example', last_name: 'Example', email: "#{Faker::Name.first_name}@example.com", password: 'secret') }

      it 'should return true' do
        user.role = role
        expect(user.it_support?).to eq(true)
      end

      it 'should return false' do
        expect(user.it_support?).to eq(false)
      end
    end

    describe '#om_support?' do
      let!(:role) { Role.create(name: 'om_support') }
      let!(:role_1) { Role.create(name: 'none') }
      let(:user) { User.create(first_name: 'Example', last_name: 'Example', email: "#{Faker::Name.first_name}@example.com", password: 'secret') }

      it 'should return true' do
        user.role = role
        expect(user.om_support?).to eq(true)
      end

      it 'should return false' do
        expect(user.om_support?).to eq(false)
      end
    end

    describe '#full_name' do
      let!(:role) { Role.create(name: 'none') }
      let(:user) { User.create(first_name: 'Example', last_name: 'Example', email: "#{Faker::Name.first_name}@example.com", password: 'secret') }

      it 'should return full name' do
        expect(user.full_name).to eq('Example Example')
      end
    end
  end

end
