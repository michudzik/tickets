require 'rails_helper'

RSpec.describe Status, type: :model do
  
  describe 'attributes' do
    it 'should have proper attributes' do
      expect(subject.attributes).to include('name')
    end
  end

  describe 'relations' do
    it { should have_many(:tickets) }
  end
  
end