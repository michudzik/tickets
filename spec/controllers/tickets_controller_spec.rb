require 'rails_helper'

RSpec.describe TicketsController, type: :controller do

  let(:admin) { create(:user, :admin) }
  let(:itsupport) { create(:user, :it_support) }
  let(:omsupport) { create(:user, :om_support) }
  let!(:user) { create(:user, :none) }
  let!(:ticket1) {Ticket.create(title: 'test', note: 'example ticket', department: 1, status: 1, user_id: user.id)}
  let!(:ticket2) {Ticket.create(title: 'test', note: 'example ticket', department: 1, status: 1, user_id: user.id)}
  let!(:ticket3) {Ticket.create(title: 'test', note: 'example ticket', department: 1, status: 1, user_id: admin.id)}


  describe '#index' do

    before do 
      sign_in user
      get :index
    end
    
    describe 'successful view of tickets list' do

    end

    describe 'successful response' do
      it { expect(response).to be_successful }
      it { expect(response).to render_template('index') }
    end
  end

  describe '#show' do
    describe 'successful response' do
      before do
        sign_in user
        get :show, params: { id: user.id } 
      end
      it { expect(response).to be_successful }
      it { expect(response).to render_template('show') }
    end
  end

end