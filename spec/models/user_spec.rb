require 'rails_helper'

RSpec.describe User, type: :model do

  describe '#filtered' do
    let(:user_1) { create(:user, locked_at: DateTime.now) }
    let(:user_2) { create(:user) }
    it "filter by locked" do
      expect(user_1.locked_at).to_not eq(nil)
    end

    it "filter by unlocked" do
      expect(user_2.locked_at).to eq(nil)
    end
  end

  describe 'attributes' do
    it 'should have proper attributes' do
      expect(subject.attributes).to include('first_name', 'last_name')
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should allow_value("email@addresse.foo").for(:email) }
    it { should_not allow_value("foo").for(:email) }
  end

  describe 'relations' do
    it { should belong_to(:role) }
    it { should have_many(:comments) }
    it { should have_many(:tickets) }
  end

  describe 'callbacks' do
    let(:user) { create(:user) }
    it 'should set role to user if not given' do
      expect(user.role.name).to eq('user')
    end
  end

  describe 'methods' do
    let!(:admin_role)        { create(:role, :admin) }
    let!(:user_role)         { create(:role) }
    let!(:it_support_role)   { create(:role, :it_support) }
    let!(:om_support_role)   { create(:role, :om_support) }
    let(:user) { create(:user) }

    describe '#same_user?' do
      it 'should return true' do
        expect(user.same_user?(user.id)).to eq(true)
      end

      it 'should return false' do
        other_user = create(:user)
        expect(user.same_user?(other_user.id)).to eq(false)
      end
    end

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

    describe '#support?' do
      context 'it support' do
        it 'should return true' do
          user.role = it_support_role
          expect(user.support?).to eq(true)
        end
      end

      context 'om support' do
        it 'should return true' do
          user.role = om_support_role
          expect(user.support?).to eq(true)
        end
      end

      context 'admin' do
        let(:admin) { create(:user, :admin) }
        it 'should return true' do
          expect(admin.support?).to eq(true)
        end
      end

      it 'should return false' do
        user.role = user_role
        expect(user.support?).to eq(false)
      end
    end

    describe '#fullname' do
      it 'should return full name' do
        expect(user.fullname).to eq("#{user.first_name} #{user.last_name}")
      end
    end
  end

  describe 'scopes' do

    context 'locked / unlocked' do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }
      before { user1.lock_access! }

      it 'should return locked user' do
        expect(User.locked).to include(user1)
        expect(User.locked).not_to include(user2)
      end

      it 'should return unlocked user' do
        expect(User.unlocked).to include(user2)
        expect(User.unlocked).not_to include(user1)
      end
    end

    context 'ordering' do
      let(:user1) { create(:user, last_name: 'abcd', email: 'abcd@example.com') }
      let(:user2) { create(:user, last_name: 'bcde', email: 'bcdef@example.com') }

      it 'should order by last_name asc' do
        expected_array = [user1, user2]
        expect(User.ordered_by_last_name_asc).to eq(expected_array)
      end

      it 'should order by last_name desc' do
        expected_array = [user2, user1]
        expect(User.ordered_by_last_name_desc).to eq(expected_array)
      end

      it 'should order by email asc' do
        expected_array = [user1, user2]
        expect(User.ordered_by_email_asc).to eq(expected_array)
      end

      it 'should order by email desc' do
        expected_array = [user2, user1]
        expect(User.ordered_by_email_desc).to eq(expected_array)
      end

    end
  end
  
end
