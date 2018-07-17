require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  
  describe '#show' do
    describe 'successful response' do
      let!(:role) { Role.create(name: 'none') }
      let!(:user) { User.create(first_name: 'example', last_name: 'example', email: "#{Faker::Name.first_name}@example.com", password: 'secret') }
      before do
        sign_in user
        user.confirmed_at = DateTime.now
        user.save
        user.reload
        get :show, params: { id: user.id } 
      end
      it { expect(response).to be_successful }
      it { expect(response).to render_template('show') }
    end
  end

end