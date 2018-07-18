require 'rails_helper'

RSpec.describe Role, type: :model do
  
  describe 'attributes' do
    it 'should have proper attributes' do
      expect(subject.attributes).to include('name')
    end
  end

  describe 'relations' do
    it { should have_many(:users) }
  end

end