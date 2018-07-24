require 'rails_helper'

RSpec.describe TicketsController, type: :controller do

  let(:admin) { create(:user, :admin) }
  let(:itsupport) { create(:user, :it_support) }
  let(:omsupport) { create(:user, :om_support) }
  let!(:user) { create(:user) }

  describe '#index' do
    before do 
      sign_in admin
      get :index 
    end

    describe 'successful response' do
      it { expect(response).to be_successful }
      it { expect(response).to render_template('index') }
    end

    context 'tickets admin' do
      let(:ticket1) { create(:ticket) }
      let(:ticket2) { create(:ticket) }
      let(:ticket3) { create(:ticket) }

      it 'should return all tickets' do
        expect(assigns(:tickets)).to match_array([ticket1, ticket2, ticket3])
      end
    end

    context 'tickets it support' do
      let(:ticket1) { create(:ticket) }
      let(:ticket2) { create(:ticket) }
      let(:ticket3) { create(:ticket) }
      let(:it_support_user) { create(:user, :it_support) }

      it 'should return all tickets' do
        sign_out admin
        sign_in it_support_user
        expect(assigns(:tickets)).to match_array([ticket1, ticket2, ticket3])
      end
    end

    context 'tickets om support' do
      let(:ticket1) { create(:ticket, :om_department) }
      let(:ticket2) { create(:ticket, :om_department) }
      let(:ticket3) { create(:ticket, :om_department) }
      let(:om_support_user) { create(:user, :om_support) }

      it 'should return all tickets' do
        sign_out admin
        sign_in om_support_user
        expect(assigns(:tickets)).to match_array([ticket1, ticket2, ticket3])
      end
    end
  end

  describe '#show' do
    let(:ticket) { create(:ticket, user_id: user.id) }
    before do
      sign_in user
      get :show, params: { id: ticket.id } 
    end

    describe 'successful response' do
      it { expect(response).to be_successful }
      it { expect(response).to render_template('show') }
    end
  end

end