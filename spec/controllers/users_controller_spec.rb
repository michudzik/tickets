require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  
  describe '#show' do
    describe 'successful response' do
      let!(:user) { User.create(first_name: 'example', last_name: 'example', email: 'example@example.com', password: 'secret') }
      before do
        sign_in user
        get :show, params: { id: user.id } 
      end
      it { expect(response).to be_successful }
      it { expect(response).to render_template('show') }
    end
  end

end