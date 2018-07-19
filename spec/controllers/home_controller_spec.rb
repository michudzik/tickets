require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  
  describe '#home' do
    subject { get :home }
    let(:user) { create(:user) }

    it 'should redirect to new_user_session when not signed in' do
      sign_in user
      expect(subject).to redirect_to user_dashboard_url
    end

    it 'should redirect to user_dashboard when user is signed in' do
      expect(subject).to redirect_to new_user_session_url
    end

  end

end